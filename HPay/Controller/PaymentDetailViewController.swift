//
//  PaymentDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
import SwiftyJSON

class PaymentDetailViewController: BaseViewController {

    @IBOutlet weak var cardView: CView!
    @IBOutlet weak var productInfoView: CView!
    @IBOutlet weak var btnPayment: CButton!
    
    var selMethod:JSON!
    var orderId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "결제", #selector(actionNaviBack))
        
        if selMethod.isEmpty == false {
            let card = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?.first as! CardView
            cardView.addSubview(card)
            card.addConstraintsSuperView(.zero)
            card.configurationData(data: selMethod)
            card.layer.cornerRadius = 16
            card.clipsToBounds = true
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPayment {
            var paymentMethodVo = [String:Any]()
            paymentMethodVo["pay_method_id"] =  selMethod["pay_method_id"].stringValue  //"payment_method_001",
            paymentMethodVo["name"] = selMethod["pay_method_name"].stringValue
            paymentMethodVo["method_type"] = selMethod["pay_method_type"].stringValue //"hpay",
            paymentMethodVo["display_order"] = selMethod["display_order"].stringValue   //1,
            paymentMethodVo["info"] = selMethod["pay_method_info"].stringValue  //"test info",
            paymentMethodVo["created_atd"] = Date().stringDateWithFormat("yyyy-MM-dd HH:mm:dd")  //"2021-07-03 14:19:24"
            
            var param = [String:Any]()
            param["userId"] = "sjahn"
            param["orderId"] = orderId!
            param["walletPassword"] = "pwd123!"
            
            param["paymentMethodVo"] = paymentMethodVo
            
            ApiManager.ins.requestProductPayment(param: param) { res in
                if res.isEmpty == false {
                    CAlertViewController.show(type: .alert, title: nil, message: "결제 성공", actions: [.ok]) { vcs, selItem, index in
                        vcs.dismiss(animated: false, completion: nil)
                        if index == 0 {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } fail: { error in
                self.showErrorToast(error)
            }
        }
    
    }
    

}
