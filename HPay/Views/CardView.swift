//
//  CardView.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit
import SwiftyJSON

class CardView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    class func loadFromNib() -> CardView {
        return Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)?.first as! CardView
    }
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svNumber: UIStackView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDate: UILabel!

    func configurationData(data: JSON) {
        
//        let display_order = data["display_order"].numberValue
        let paymethod_expire = data["paymethod_expire"].stringValue
        let paymethod_holder = data["paymethod_holder"].stringValue
//        let paymethod_id = data["paymethod_id"].stringValue
        let paymethod_info = data["paymethod_info"].stringValue
        let paymethod_name = data["paymethod_name"].stringValue
//        let paymethod_type = data["paymethod_type"].stringValue
        
//        let pay_method_id = data["pay_method_id"].numberValue  //3,
//        let pay_method_type = data["pay_method_type"].stringValue  //"CARD",
        let pay_method_info = data["pay_method_info"].stringValue  //"1234-1313-2342-5555",
        let pay_method_name = data["pay_method_name"].stringValue  //"hpay",
        let pay_method_expire = data["pay_method_expire"].stringValue  //"11\/22",
        let pay_method_holder = data["pay_method_holder"].stringValue  //"Kim jin su",
//        let display_order = data["display_order"]  //9999

        
        var numbers = [String]()
        if paymethod_info.isEmpty == false {
            numbers = paymethod_info.components(separatedBy: "-")
        }
        else {
            numbers = pay_method_info.components(separatedBy: "-")
        }
        
        for subView in svNumber.subviews {
            subView.removeFromSuperview()
        }
        
        for number in numbers {
            let lbNum = UILabel()
            lbNum.textColor = UIColor.white
            lbNum.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            svNumber.addArrangedSubview(lbNum)
            lbNum.text = number
            lbNum.textAlignment = .center
        }
        
        lbTitle.text = (paymethod_name.isEmpty == false) ? paymethod_name : pay_method_name
        lbName.text = (paymethod_holder.isEmpty == false) ? paymethod_holder : pay_method_holder
        lbDate.text = (paymethod_expire.isEmpty == false) ? paymethod_expire : pay_method_expire
    }
}
