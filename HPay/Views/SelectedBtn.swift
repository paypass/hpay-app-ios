//
//  SelectedBtn.swift
//  HPay
//
//  Created by 김학철 on 2021/07/06.
//

import UIKit

class SelectedBtn: CButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.borderColor = UIColor(named: "AccentColor")
                self.borderWidth = 2
                self.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
            }
            else {
                self.borderColor = UIColor.lightGray
                self.borderWidth = 1
                self.setTitleColor(UIColor.label, for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }
    }
}
