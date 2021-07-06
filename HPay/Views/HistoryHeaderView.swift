//
//  HisotoryHeaderView.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit

class HistoryHeaderView: UIView {
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnTime: UIButton!
    @IBOutlet weak var btnAmount: UIButton!
    @IBOutlet weak var btnIn: UIButton!
    @IBOutlet weak var btnOut: UIButton!
    
    var completion:((_ index:Int) -> Void)?
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
        if sender == btnTime {
            self.completion?(100)
        }
        else if sender == btnAmount {
            self.completion?(200)
        }
        else if sender == btnIn {
            self.completion?(300)
        }
        else if sender == btnOut {
            self.completion?(400)
        }
        else if sender == btnMore {
            self.completion?(500)
        }
    }
}
