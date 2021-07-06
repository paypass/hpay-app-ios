//
//  CardPagerCell.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit
import SwiftyJSON

class CardPagerCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    var cardView: CardView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUi()
    }
    func setUi() {
        self.cardView = CardView.loadFromNib()
        self.bgView.addSubview(cardView)
        cardView.addConstraintsSuperView(UIEdgeInsets.zero)
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
    }
    
    func configurationData(_ data: JSON) {
        
    }
}
