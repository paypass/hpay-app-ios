//
//  CaptureVideoView.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit
import AVFoundation

class CaptureVideoView: UIView {
    var player: AVAudioPlayer?
    var session = AVCaptureSession.init()
    var captureLayer: AVCaptureVideoPreviewLayer!
    var enableCapture: Bool = false
    
    var didfinishCaputure:((_ orign:UIImage?, _ crop: UIImage?) ->Void)?
    var timer: Timer?
    var captureImg: UIImage?
    
    @IBInspectable var captureInterval: TimeInterval = 0 {
        didSet {
            
        }
    }
    @IBInspectable var systemSoundName: String? {
        didSet {
            self.settingAudioPlayer()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkPermission()
    }
    
    func checkPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .denied {
            let alert = UIAlertController(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction.init(title: "Setting", style: .default, handler: { action in
                guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                    alert.dismiss(animated: true, completion: nil)
                    return
                }
                UIApplication.shared.open(url, options:[:], completionHandler: nil)
            }))
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.initializeCaptuere()
                    }
                }
            }
        }
        else {
            self.initializeCaptuere()
        }
    }
    private func initializeCaptuere() {
        session.stopRunning()
        session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput.init(device: device)
            guard session.canAddInput(input) else { return }
            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

            output.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "cameraQueue")
            output.setSampleBufferDelegate(self, queue: queue)

            session.addOutput(output)

            self.captureLayer = AVCaptureVideoPreviewLayer.init(session: session)
            captureLayer.frame = self.bounds
            captureLayer.videoGravity = .resizeAspectFill
            captureLayer.connection?.videoOrientation = .portrait

            self.layer .addSublayer(captureLayer)

            session.startRunning()

        }
        catch {
            print("video capture session can not create")
        }
    }
    
    public func startCapture() {
        stopCapture()
        self.enableCapture = true
        if captureInterval > 0 {
            self.timer = Timer.scheduledTimer(withTimeInterval: captureInterval, repeats: true, block: {[weak self] timer in
                self?.enableCapture = true
            })
        }
    }
    
    public func stopCapture() {
        self.enableCapture = false
        self.stopTimer()
    }
    private func stopTimer() {
        enableCapture = false
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        timer.fire()
    }
    deinit {
        stopTimer()
    }
}

extension CaptureVideoView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func convert(cmage: CIImage) -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
         let image = UIImage(cgImage: cgImage)
         return image
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), enableCapture else { return }
        
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciimage, from: ciimage.extent) else { return }
        
        let newImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
        self.enableCapture = false

        let crop = newImage.cropCameraImage(captureLayer)
        DispatchQueue.main.async {
            if let completion = self.didfinishCaputure {
                completion(self.captureImg, crop)
            }
        }
    }
    
    func settingAudioPlayer() {
        guard let soundName = systemSoundName, let url = findSystemSoundUrl(soundName: soundName) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player!.volume = 0.8
        }
        catch {
            print("audio player error")
        }
    }

    func findSystemSoundUrl(soundName:String) -> URL? {
        guard let directoryURL = URL(string: "/System/Library/Audio/UISounds") else { return nil }
        let localFileManager = FileManager()
        
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        let directoryEnumerator = localFileManager.enumerator(at: directoryURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
        
        var fileURLs: [URL] = []
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let name = resourceValues.name
            else {
                continue
            }
            
            if isDirectory {
                if name == "_extras" {
                    directoryEnumerator.skipDescendants()
                }
            } else {
                fileURLs.append(fileURL)
            }
        }
//        print(fileURLs)
        var findUrl: URL? = nil
        for url in fileURLs {
            if url.absoluteString.contains(soundName) == true {
                findUrl = url
                break
            }
        }
        print("find system audio url: \(String(describing: findUrl))")
        return findUrl
    }
}
extension UIImage {
    func cropCameraImage(_ previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        let previewImageLayerBounds = previewLayer.bounds
        let originalWidth = size.width
        let originalHeight = size.height

        let A = previewImageLayerBounds.origin
        let B = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.origin.y)
        let D = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.size.height)

        let a = previewLayer.captureDevicePointConverted(fromLayerPoint: A)
        let b = previewLayer.captureDevicePointConverted(fromLayerPoint: B)
        let d = previewLayer.captureDevicePointConverted(fromLayerPoint: D)
        let posX = floor(b.x * originalHeight)
        let posY = floor(b.y * originalWidth)

        let width: CGFloat = d.x * originalHeight - b.x * originalHeight
        let height: CGFloat = a.y * originalWidth - b.y * originalWidth

        let cropRect = CGRect(x: posX, y: posY, width: width, height: height)

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: 2.5, orientation: imageOrientation)
    }
    
}
