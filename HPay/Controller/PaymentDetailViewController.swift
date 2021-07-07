//
//  PaymentDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
import SwiftyJSON

class PaymentDetailViewController: BaseViewController {

    @IBOutlet weak var cardView: CView!
    @IBOutlet weak var productInfoView: CView!
    @IBOutlet weak var btnPayment: CButton!
    
    var selMethod:JSON!
    var productInfo:String!
    
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
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    

}
