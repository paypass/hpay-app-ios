//
//  AddPaymentViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit

class AddPaymentViewController: BaseViewController {

    @IBOutlet weak var btnRegist: CButton!
    @IBOutlet weak var btnMode: CButton!
    @IBOutlet weak var tfMode: CTextField!
    @IBOutlet weak var tfCardNum: CTextField!
    @IBOutlet weak var tfName: CTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CNavigationBar.drawBackButton(self, "결재수단 추가", #selector(actionNaviBack))
        
        self.addTapGestureKeyBoardDown()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotification()
    }
    
    @IBAction func onClickedButtonActions(_ sender: UIButton) {
        if sender == btnMode {
            let mode = ["HPAY", "BANK", "CARD"]
            let vc = PopupListViewController.initWithType(.normal, "선택해 주세요.", mode, nil) { vcs, selItem, index in
                vcs.dismiss(animated: true, completion: nil)
                guard let selItem = selItem as? String else {
                    return
                }
                self.tfMode.text = selItem
            }
            self.presentPanModal(vc)
        }
        
    }
}
