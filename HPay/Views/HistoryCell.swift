//
//  HistoryCell.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SwiftyJSON

class HistoryCell: UITableViewCell {

    @IBOutlet weak var btnState: CButton!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
        bgView.layer.cornerRadius = 16
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
        if highlighted {
            bgView.layer.borderWidth = 2.0
            bgView.layer.borderColor = RGBA(37, 27, 151, 0.3).cgColor
        }
        else {
            bgView.layer.borderWidth = 0
            bgView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func configurationData(data: JSON) {
        let amount = data["amount"].numberValue
        let shop_name = data["shop_name"].stringValue // hanpass;
        let transaction_date = data["transaction_date"].stringValue // "2021-06-12";
        let transaction_type = data["transaction_type"].stringValue // PAYMENT;
     
        lbTitle.text = shop_name
        lbDate.text = transaction_date
        
        if transaction_type == "CHARGE" {
            btnState.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
            btnState.tintColor = UIColor.systemPink
        }
        else {
            btnState.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            btnState.tintColor = UIColor.systemGreen
        }
        let strAmount = amount.stringValue.addComma()
        lbAmount.text = "₩\(strAmount)"
        
    }
}
