//
//  PaymentDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
import SwiftyJSON

class PaymentDetailViewController: BaseViewController {
    @IBOutlet weak var lbPartnerName: UILabel!
    @IBOutlet weak var lbOrderNumber: UILabel!
    @IBOutlet weak var lbTax: UILabel!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTotalAmount: UILabel!
    
    @IBOutlet weak var cardView: CView!
    @IBOutlet weak var productInfoView: CView!
    @IBOutlet weak var btnPayment: CButton!
    
    var selMethod:JSON!
    var orderId:String!
    var data:JSON!
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
        
        self.requestOderProductDetailInfo()
    }
    func requestOderProductDetailInfo() {
        ApiManager.ins.requestOderProductDetailInfo(otid: self.orderId) { res in
            if (res.isEmpty == false) {
                self.data = res
                self.reloadUi()
            }
            else {
                self.view.makeToast("상품 상세 정보 요청 에러")
            }
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func reloadUi() {
        let partner_key = data["partner_key"].stringValue  // "han-ggavquipap",
        let partner_user_id = data["partner_user_id"].stringValue  // "hanpass",
        let partner_order_id = data["partner_order_id"].stringValue  // "H-939393-SEES",
        let partner_item_name = data["partner_item_name"].stringValue  // "notebook",
        let partner_item_qty = data["partner_item_qty"].numberValue  // 1,
        let total_amount = data["total_amount"].numberValue  // 100000,
        let vat_amount = data["vat_amount"].numberValue  // 2000,
        let created_at = data["created_at"].stringValue  // "2021-06-25T00:13:47.623759"
        
        
        lbPartnerName.text = partner_key
        lbOrderNumber.text = partner_order_id
        lbTax.text = "₩"+vat_amount.stringValue.addComma()
        lbProductName.text = partner_item_name+" X "+partner_item_qty.stringValue + "개"
        
        
    
        lbTotalAmount.text = "￦"+total_amount.stringValue.addComma()
        
        let df = CDateFormatter.init()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        if let date = df.date(from: created_at) {
            df.dateFormat = "yyyy.MM.dd HH:mm:ss"
            let dateStr = df.string(from: date)
            lbDate.text = dateStr
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
