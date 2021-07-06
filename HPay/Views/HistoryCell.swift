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
        
    }
}
