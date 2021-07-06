//
//  PaymentDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit

class PaymentDetailViewController: BaseViewController {

    @IBOutlet weak var cardView: CView!
    @IBOutlet weak var productInfoView: CView!
    @IBOutlet weak var btnPayment: CButton!
    var data: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "결제", #selector(actionNaviBack))
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    }
    

}
