//
//  PaymentManagerViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
class PaymentManagerCell: UITableViewCell {
    static let identifier = "PaymentManagerCell"
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var btnMore: UIButton!
    
    var completion:((_ index: Int) ->Void)?
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
    
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnMore {
            self.completion?(100)
        }
    }
}
class PaymentManagerViewController: BaseViewController {
    @IBOutlet weak var btnPay: CButton!
    @IBOutlet weak var btnBank: CButton!
    @IBOutlet weak var btnCard: CButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.layer.cornerRadius = 24
        self.bgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        CNavigationBar.drawBackButton(self, "결재수단 관리", #selector(actionNaviBack))
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tblView.bounds.size.width, height: 24))
        tblView.tableHeaderView = headerView
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
    }
    
}
extension PaymentManagerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentManagerCell.identifier) as? PaymentManagerCell else {
            return UITableViewCell()
        }
        return cell
    }
}
