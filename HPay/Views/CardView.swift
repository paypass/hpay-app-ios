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
        
    }
}
