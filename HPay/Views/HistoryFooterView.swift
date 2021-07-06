//
//  HistoryFooterView.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit

class HistoryFooterView: UIView {
    @IBOutlet weak var btnMore: UIButton!
    var completion:((_ index:Int) -> Void)?
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnMore {
            completion?(100)
        }
    }
}
