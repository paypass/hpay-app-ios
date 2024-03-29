//
//  CameraController.swift
//

import AVFoundation
import Photos
import UIKit

class CameraController: UIViewController {
    enum Camera {
        case front, back
    }

    /// The current active camera.
    private(set) var camera = Camera.back

    private lazy var session = AVCaptureSession()
    private lazy var photoOutput = AVCapturePhotoOutput()

    private var activeCamera: AVCaptureDevice?
    private lazy var frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private lazy var backCamera: AVCaptureDevice? = {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    }()

    private lazy var previewView = UIView()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)

    private let currentDevice = UIDevice.current // Used to determine the image orientation.

    /// A range to determine minimum and maximum zoom factor.
    ///
    /// This value will be intersected with `AVCaptureDevice.minAvailableVideoZoomFactor` and `AVCaptureDevice.maxAvailableVideoZoomFactor` before being applied.
    var zoomScaleRange: ClosedRange<CGFloat> = 1...10

    private let sessionQueue = DispatchQueue(label: "Session Queue")

    private var sessionSetupSucceeds = false

    private var captureProcessors: [Int64: PhotoCaptureProcessor] = [:]

    private var videoOrientation: AVCaptureVideoOrientation = .portrait

    override func viewDidLoad() {
        super.viewDidLoad()

        // `AVCaptureVideoPreviewLayer` must be set up before we configure `AVCaptureSession` in a different queue.
        previewLayer.videoGravity = .resizeAspectFill
        previewView.frame = view.bounds
        previewView.layer.addSublayer(previewLayer)
        view.insertSubview(previewView, at: 0)

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { [unowned self] in
                self.configureSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                if granted {
                    sessionQueue.async { [unowned self] in
                        self.configureSession()
                        self.session.startRunning()
                    }
                }
            }
        default:
            break
        }

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        previewView.addGestureRecognizer(pinch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        previewView.addGestureRecognizer(tap)

        setVideoOrientationForDeviceOrientation(currentDevice.orientation)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceOrientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
    }

    @objc
    func didInterrupted() {
        print(session.isInterrupted)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.stopRunning()
            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = previewView.layer.bounds
    }

    func setCamera(_ camera: Camera) {
        guard sessionSetupSucceeds else { return }

        if camera == self.camera { return }

        sessionQueue.async { [unowned self] in
            self.session.beginConfiguration()
            self._setCamera(camera)
            self.session.commitConfiguration()
        }
    }

    func takePhoto(_ completion: ((Photo) -> Void)? = nil) {
        guard sessionSetupSucceeds else { return }

        let settings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }

        let orientation = videoOrientation

        // Update the photo output's connection to match current device's orientation
        photoOutput.connection(with: .video)?.videoOrientation = orientation

        let processor = PhotoCaptureProcessor()
        processor.orientation = orientation
        processor.completion = { [unowned self] processor in
            if let photo = processor.photo {
                PHPhotoLibrary.shared().performChanges({
                    // Add the captured photo's file data as the main resource for the Photos asset.
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                }, completionHandler: nil)

                completion?(Photo(photo: photo, orientation: processor.orientation))
            }

            if let settings = processor.settings {
                let id = settings.uniqueID
                self.captureProcessors.removeValue(forKey: id)
            }
        }
        captureProcessors[settings.uniqueID] = processor

        sessionQueue.async { [unowned self] in
            self.photoOutput.capturePhoto(with: settings, delegate: processor)
        }
    }

    // Call this on the `sessionQueue`.
    private func configureSession() {
        self.session.beginConfiguration()

        self.session.sessionPreset = .photo

        if backCamera != nil {
            _setCamera(.back)
        } else if frontCamera != nil {
            _setCamera(.front)
        } else {
            return
        }

        self.photoOutput.isHighResolutionCaptureEnabled = true
        guard self.session.canAddOutput(self.photoOutput) else {
            return
        }
        self.session.addOutput(self.photoOutput)

        self.session.commitConfiguration()

        sessionSetupSucceeds = true
    }

    /// You should nest the call to this function with `beginConfiguration()` and `commitConfiguration()`.
    private func _setCamera(_ camera: Camera) {
        let newDevice: AVCaptureDevice?
        switch camera {
        case .front:
            newDevice = frontCamera
        case .back:
            newDevice = backCamera
        }

        if let _currentInput = session.inputs.first {
            session.removeInput(_currentInput)
        }

        guard
            let device = newDevice,
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else { return }

        session.addInput(input)

        self.camera = camera
        activeCamera = device
    }

    private func configCamera(_ camera: AVCaptureDevice?, _ config: @escaping (AVCaptureDevice) -> ()) {
        guard let device = camera else { return }

        sessionQueue.async { [device] in
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }

            config(device)

            device.unlockForConfiguration()
        }
    }

    private var initialScale: CGFloat = 0

    @objc
    private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard sessionSetupSucceeds,  let device = activeCamera else { return }

        switch pinch.state {
        case .began:
            initialScale = device.videoZoomFactor
        case .changed:
            let minAvailableZoomScale = device.minAvailableVideoZoomFactor
            let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
            let availableZoomScaleRange = minAvailableZoomScale...maxAvailableZoomScale
            let resolvedZoomScaleRange = zoomScaleRange.clamped(to: availableZoomScaleRange)

            let resolvedScale = max(resolvedZoomScaleRange.lowerBound, min(pinch.scale * initialScale, resolvedZoomScaleRange.upperBound))

            configCamera(device) { device in
                device.videoZoomFactor = resolvedScale
            }
        default:
            return
        }
    }

    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        guard sessionSetupSucceeds else { return }

        let point = tap.location(in: previewView)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

        configCamera(activeCamera) { device in
            let focusMode = AVCaptureDevice.FocusMode.autoFocus
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = devicePoint
                device.focusMode = focusMode
            }

            let exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = devicePoint
                device.exposureMode = exposureMode
            }
        }

        // Animate focusing
    }

    @objc
    private func deviceOrientationChanged(_ note: Notification) {
        setVideoOrientationForDeviceOrientation(currentDevice.orientation)
    }

    private func setVideoOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            break
        }
    }
}

// MARK: - CameraController.Photo

extension CameraController {
    /// An object to represent the result photo taken with the camera
    class Photo {
        private let photo: AVCapturePhoto
        private let orientation: AVCaptureVideoOrientation

        fileprivate init(photo: AVCapturePhoto, orientation: AVCaptureVideoOrientation) {
            self.photo = photo
            self.orientation = orientation
        }

        func image() -> UIImage? {
            guard let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() else { return nil }

            let imageOrientation: UIImage.Orientation
            switch orientation {
            case .portrait:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .left
            case .landscapeRight:
                imageOrientation = .up
            case .landscapeLeft:
                imageOrientation = .down
                @unknown default:
                    fatalError()
            }

            return UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
        }
    }
}

// MARK: - PhotoCaptureProcessor

private class PhotoCaptureProcessor: NSObject {
    var photo: AVCapturePhoto?
    var completion: ((PhotoCaptureProcessor) -> Void)?
    var settings: AVCaptureResolvedPhotoSettings?
    var orientation: AVCaptureVideoOrientation = .portrait
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        print("aaa")
        self.photo = photo
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            return
        }

        self.settings = resolvedSettings
        print("bbb")
        completion?(self)
    }
}
