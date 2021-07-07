//
//  ChargeViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SwiftyJSON

class ChargeViewController: BaseViewController {

    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var tfAmount: CTextField!
    @IBOutlet weak var btnCharge: CButton!
    var data:[JSON] = [JSON]()
    var selMethod:JSON = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPagerView()
        self.requestPaymentMethodList()
       
//        let attr = NSAttributedString.init(string: "0", attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.5)])
//        tfAmount.attributedPlaceholder = attr
        
        self.addTapGestureKeyBoardDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigation()
        self.addKeyboardNotification()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tfAmount.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    func setNavigation() {
        CNavigationBar.drawLeftBarItem(self, "list.bullet", nil, TAG_NAVI_MEMU, #selector(actionNaviMenu))
        let attr = NSAttributedString.init(string: "충전", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .black)])
        CNavigationBar.drawTitle(self, attr, nil)
        CNavigationBar.drawRight(self, "bell.badge", nil, TAG_NAVI_BELL, #selector(actionNaviBell))
    }
    
    func setupPagerView() {
        pagerView.register(UINib(nibName: "CardPagerCell", bundle: nil), forCellWithReuseIdentifier: "CardPagerCell")
//        pagerView.automaticSlidingInterval = 3.0
//        pagerView.isInfinite = true
//        pagerView.decelerationDistance = FSPagerView.automaticDistance
//        pagerView.transformer = FSPagerViewTransformer(type: .linear)
//        pagerView.transformer?.minimumScale = 0.85
        pagerView.interitemSpacing = 10
//        pagerView.scrollDirection = .horizontal
      
        let scale = CGFloat(0.9)
        let itemSize = pagerView.frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        pagerView.itemSize = itemSize
        
        pagerView.delegate = self
        pagerView.dataSource = self
    }
    
    func requestPaymentMethodList() {
        ApiManager.ins.requestRegisteredPaymentMethods { res in
            print("payment method list: \(res)")
            if res.isEmpty == false {
                self.data = res.arrayValue
                self.pagerView.reloadData()
                self.selMethod = self.data[0]
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
        if sender == btnCharge {
            self.view.endEditing(true)
            
            guard let text = tfAmount.text, let amount = text.getNumberString(), amount.isEmpty == false else {
                self.showToast("금액을 입력해주세요.")
                return
            }
            var param = [String:Any]()
            param["charge_type"] = selMethod["pay_method_type"].stringValue //   : "DEDUCTION",
            param["wallet_id"] = ShareData.ins.walletId  //   :19,
            param["pay_method_id"] =  selMethod["pay_method_id"].stringValue //   : 1,
            param["charge_amount"] = Int(amount) //   : 5000000,
            param["wallet_password"] = "password"
            
            ApiManager.ins.requestChargeHPay(param: param) { res in
                if res.isEmpty == false {
                    self.showErrorToast("충전이 완료되었습니다.")
                    self.tfAmount.text = ""
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    }
    
    @IBAction func textFiledEdtingChanged(_ textFiled: UITextField) {
        guard let text = textFiled.text, text.isEmpty == false else {
            return
        }
        guard let delStr = text.getNumberString(), delStr.isEmpty == false else {
            return
        }
        
        let newStr = delStr.addComma()
        textFiled.text = newStr
    }
    
}
extension ChargeViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return data.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "CardPagerCell", at: index) as! CardPagerCell
        let item = data[index]
        cell.configurationData(item, index)
        return cell
    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.selMethod = data[targetIndex]
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        
    }
}

extension ChargeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = UIColor.init(white: 1, alpha: 0.3)
            textField.borderWidth = 2
            textField.setNeedsDisplay()
        }
    }
    func textFieldDidEndEditing(_ textField:UITextField) {
        if let textField = textField as? CTextField {
            textField.borderColor = UIColor.clear
            textField.borderWidth = 0
            textField.setNeedsDisplay()
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let text = textField.text, text.isEmpty == false {
//            let delStr = text.delComma()
//            let strTxt = (delStr as NSString?)!.replacingCharacters(in: range, with: string)
//            let newStr = strTxt.addComma()
//            textField.text = newStr
//        }
//        return true
//    }
}
