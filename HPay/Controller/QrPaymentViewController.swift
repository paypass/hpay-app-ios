//
//  QrPaymentViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SwiftyJSON
import AVFoundation
import TapQRCode_iOS

class QrPaymentViewController: BaseViewController {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var ivScanAni: UIImageView!
    @IBOutlet weak var btnQrFocus: UIButton!
    @IBOutlet weak var fucusingview: UIView!
    @IBOutlet weak var btnPay: SelectedBtn!
    @IBOutlet weak var btnBank: SelectedBtn!
    @IBOutlet weak var btnCard: SelectedBtn!
    @IBOutlet weak var qrScanView: CaptureVideoView!
    @IBOutlet weak var widthFucusingView: NSLayoutConstraint!
    @IBOutlet weak var yPosLineView: NSLayoutConstraint!
    
    var data:JSON!
    var methods: [JSON] = [] {
        didSet {
            self.selMethod = methods[0]
            self.pagerView.reloadData()
        }
    }
    var selMethod:JSON!
    var isScan = false
    var cards:[JSON] = []
    var revers:CGFloat = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 20
        bgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
    
        let layer = CAShapeLayer.init()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = nil
        layer.lineWidth = 5.0
        layer.lineDashPattern = [24, 24]
        layer.frame = fucusingview.layer.bounds
        layer.path = UIBezierPath(roundedRect: fucusingview.bounds, cornerRadius: 24).cgPath
        fucusingview.layer.addSublayer(layer)
        
        widthFucusingView.constant = ceil(self.view.bounds.width*0.75)
        
        let item:JSON = JSON(["cardNo": "123456789", "name":"Kim Jong Un"])
        cards.append(item)
        cards.append(item)
        cards.append(item)
        
        self.setupPagerView()
        qrScanView.captureInterval = 0.5
        qrScanView.systemSoundName = "access_scan_complete"
        self.requestPaymentMethodList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigation()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrScanView.stopCapture()
        isScan = false
    }
    
    func setNavigation() {
        CNavigationBar.drawLeftBarItem(self, "list.bullet", nil, TAG_NAVI_MEMU, #selector(actionNaviMenu))
        let attr = NSAttributedString.init(string: "QR Scan", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .black)])
        CNavigationBar.drawTitle(self, attr, nil)
        CNavigationBar.drawRight(self, "bell.badge", nil, TAG_NAVI_BELL, #selector(actionNaviBell))
    }
    
    func setupPagerView() {
        pagerView.register(UINib(nibName: "CardPagerCell", bundle: nil), forCellWithReuseIdentifier: "CardPagerCell")
//        pagerView.automaticSlidingInterval = 3.0
//        pagerView.isInfinite = true
//        pagerView.decelerationDistance = FSPagerView.automaticDistance
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
//        pagerView.transformer?.minimumScale = 0.85
        pagerView.interitemSpacing = 10
        pagerView.scrollDirection = .horizontal
      
        let scale = CGFloat(0.85)
        let itemSize = pagerView.frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        pagerView.itemSize = itemSize
        
        
        pagerView.delegate = self
        pagerView.dataSource = self
    }
    func requestPaymentMethodList() {
        ApiManager.ins.requestRegisteredPaymentMethods { res in
            print("payment method list: \(res)")
            if res.isEmpty == false {
                let group = Dictionary(grouping: res.arrayValue) { (item:JSON) in
                    return item["pay_method_type"].stringValue
                }
                self.data = JSON(group)
                self.btnPay.sendActions(for: .touchUpInside)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPay {
            btnPay.isSelected = true
            btnBank.isSelected = false
            btnCard.isSelected = false
            self.methods = data["HPAY"].arrayValue
        }
        else if sender == btnBank {
            btnPay.isSelected = false
            btnBank.isSelected = true
            btnCard.isSelected = false
            self.methods = data["BANK"].arrayValue
        }
        else if sender == btnCard {
            btnPay.isSelected = false
            btnBank.isSelected = false
            btnCard.isSelected = true
            self.methods = data["CARD"].arrayValue
        }
        else if sender == btnQrFocus {
            isScan = !isScan
            if isScan {
                self.startAniLineView()
//                self.aniFucusing()
                qrScanView.startCapture()
                qrScanView.didfinishCaputure = {(orin: UIImage?, crop:UIImage?) in
                    guard let crop = crop else {
                        return
                    }
                    self.decoderQrImage(crop)
                }
            }
            else {
                qrScanView.stopCapture()
            }
        }
    }
    
    func startAniLineView() {
        if isScan == false {
            return
        }
        let height = ceil(self.view.bounds.width*0.75)
        yPosLineView.constant = revers*(height/2)
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        } completion: { finish in
            self.yPosLineView.constant = (-self.revers * (height/2))
            UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()
            } completion: { finish in
                self.revers = (-1*self.revers)
                self.startAniLineView()
            }
        }
    }
    func aniFucusing() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn) {
            self.fucusingview.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { finished in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) {
                self.fucusingview.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { finished in
            }
        }
    }
    
    func decoderQrImage(_ image: UIImage) {
        let res:TapQRCodeScannerResult = TapQRCodeScanner().scan(from: image)
        guard let data = res.scannedText, data.isEmpty == false else {
            return
        }
        
        print("scan data: \(data)")
        
        guard let jsDic = data.parsingJsonObject(),
              let partnerKey = jsDic["partnerKey"] as? String,
              partnerKey.lowercased() == "hanpass" else {
            self.view.makeToast("파트너 회사에서 발급한 유효한 QR코드가 아닙니다.")
            return
        }
        guard let otid = jsDic["otid"] as? String, otid.isEmpty == false else {
            self.view.makeToast("qr code otid is empty")
            return
        }

        qrScanView.player?.play()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let vc = PaymentDetailViewController.instantiateFromStoryboard(.main)!
        vc.selMethod = selMethod
        vc.orderId = otid
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension QrPaymentViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return methods.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "CardPagerCell", at: index) as! CardPagerCell
        let item = methods[index]
        cell.configurationData(item, index)
        return cell
    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.selMethod = methods[targetIndex]
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
    }
}
