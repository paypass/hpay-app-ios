//
//  AddPaymentViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
import SwiftyJSON

class AddPaymentViewController: BaseViewController {

    @IBOutlet weak var btnRegist: CButton!
    @IBOutlet weak var btnMode: CButton!
    @IBOutlet weak var btnMethod: CButton!
    
    @IBOutlet weak var svMehtod: UIStackView!
    @IBOutlet weak var svCardNumber: UIStackView!
    @IBOutlet weak var tfCardNum: CTextField!
    @IBOutlet weak var svName: UIStackView!
    @IBOutlet weak var tfName: CTextField!
    @IBOutlet weak var bottomCon: NSLayoutConstraint!
    
    var methods:[JSON]!
    var selMethod:JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "결재수단 추가", #selector(actionNaviBack))
        
        self.addTapGestureKeyBoardDown()
        
        self.svMehtod.isHidden = true
        self.svCardNumber.isHidden = true
        self.svName.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationHandler(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func requestRegistAvailablePayment(_ method:String) {
        ApiManager.ins.requestRegistAvailablePayment(method: method) { res in
            if res.isEmpty == false {
                self.methods = res.arrayValue
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnMode {
            let mode = ["BANK", "CARD"]
            let vc = PopupListViewController.initWithType(.normal, "선택해 주세요.", mode, nil) { vcs, selItem, index in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                guard let tfMode = self.btnMode.viewWithTag(100) as? CTextField else {
                    return
                }
                
                tfMode.text = selItem
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.svMehtod.isHidden = false
                    self.svName.isHidden = true
                    self.svCardNumber.isHidden = true
                } completion: { finish in
                    guard let lbMethod = self.svMehtod.viewWithTag(10) as? UILabel else {
                        return
                    }
                    if selItem == "BANK" {
                        lbMethod.text = "은행"
                    }
                    else {
                        lbMethod.text = "카드사"
                    }
                }
                self.requestRegistAvailablePayment(selItem)
            }
            self.presentPanModal(vc)
        }
        else if sender == btnMethod {
            guard let methods = methods, methods.isEmpty == false else {
                return
            }
            let keys:[String] = ["pay_method_name"]
            let vc = PopupListViewController.initWithType(.normal, "선택해 주세요.", methods, keys) { (vcs, selItem, index) in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? JSON else {
                    return
                }
                guard let tfMethod = self.btnMethod.viewWithTag(100) as? CTextField else {
                    return
                }
                
                tfMethod.text = selItem["pay_method_name"].stringValue
                self.selMethod = selItem
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.svCardNumber.isHidden = false
                    self.svName.isHidden = false
                } completion: { finish in
                    
                }
            }
            self.presentPanModal(vc)
        }
        else if sender == btnRegist {
            guard let tfMode = self.btnMode.viewWithTag(100) as? CTextField else {
                return
            }
            
            guard let method = tfMode.text, method.isEmpty == false else {
                self.showToast("결제수단을 선택해주세요.")
                return
            }
            
            guard selMethod.isEmpty == false else {
                self.showToast("은행명을 선택해주세요.")
                return
            }
            guard let cardNumber = tfMode.text, cardNumber.isEmpty == false else {
                self.showToast("카드번호를 입력해주세요.")
                return
            }
            guard let cardName = tfMode.text, cardName.isEmpty == false else {
                self.showToast("카드 별칭을 입력해주세요.")
                return
            }
            
            
            var param = [String:Any]()
            param["method_type"] = method
            param["method_code"] = selMethod["pay_method_code"].stringValue
            param["wallet_id"] = ShareData.ins.walletId
            param["method_name"] = selMethod["pay_method_name"].stringValue
            param["method_info"] = cardNumber
            param["verify_code"] = "111"
            
            ApiManager.ins.requestRegistPaymentMethod(param: param) { res in
                let code = res["code"].stringValue
                let message = res["message"].stringValue
                
                CAlertViewController.show(type: .alert, title:nil , message:"등록 성공", actions:[.ok]) { (vcs, item, index) in
                    vcs.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    }
    
    @objc override func notificationHandler(_ notification: NSNotification) {
        if notification.name == UIResponder.keyboardWillShowNotification
            || notification.name == UIResponder.keyboardWillHideNotification {
            
            let heightKeyboard = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            let duration = CGFloat((notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.0)
            
            
            if notification.name == UIResponder.keyboardWillShowNotification {
                var tabBarHeight:CGFloat = 0.0
                if self.navigationController?.tabBarController?.tabBar.isHidden == false {
                    tabBarHeight = self.navigationController?.toolbar.bounds.height ?? 0.0
                }
                let safeBottom:CGFloat = sceneDelegate.window?.safeAreaInsets.bottom ?? 0
                bottomCon.constant = heightKeyboard - safeBottom - tabBarHeight + 24
                UIView.animate(withDuration: TimeInterval(duration), animations: { [self] in
                    self.view.layoutIfNeeded()
                })
            }
            else if notification.name == UIResponder.keyboardWillHideNotification {
                bottomCon.constant = 24
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

