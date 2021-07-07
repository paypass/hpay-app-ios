//
//  PaymentManagerViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit
import SwiftyJSON

class PaymentManagerCell: UITableViewCell {
    static let identifier = "PaymentManagerCell"
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbSubtitle: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var btnXmark: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    
    @IBOutlet weak var edtingView: CView!
    var completionBlock:((_ index: Int, _ data:JSON?) ->Void)?
    var data: JSON!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView()
        bgView.layer.cornerRadius = 16
        
        btnXmark.layer.cornerRadius = 8
        btnXmark.layer.maskedCorners = CACornerMask(TL: false, TR: true, BL: false, BR: true)
        btnTrash.layer.cornerRadius = 8
        btnTrash.layer.maskedCorners = CACornerMask(TL: false, TR: true, BL: false, BR: true)
        btnPencil.layer.cornerRadius = 8
        btnPencil.layer.maskedCorners = CACornerMask(TL: false, TR: true, BL: false, BR: true)
        
        edtingView.isHidden = true
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
    
    func configuraionData(_ data: JSON) {
        self.data = data
        self.edtingView.isHidden = true
        self.btnMore.isHidden = false
        
        let pay_method_holder = data["pay_method_holder"].stringValue    // "Kim jin su",
        let pay_method_type = data["pay_method_type"].stringValue    // "HPAY",
        let pay_method_id = data["pay_method_id"].stringValue    // 1,
        let pay_method_expire = data["pay_method_expire"].stringValue    // "11\/22",
        let pay_method_name = data["pay_method_name"].stringValue    // "hpay",
        let display_order = data["display_order"].stringValue    // 9999,
        let pay_method_info = data["pay_method_info"].stringValue    // "1234-1313-2342-1111"
        
        
        lbTitle.text = pay_method_name
        lbSubtitle.text = pay_method_info
    }
    @IBAction func onClickedBtnAction(_ sender: UIButton) {
        if sender == btnMore {
            edtingView.isHidden = false
            btnMore.isHidden = true
        }
        else if sender == btnXmark {
            edtingView.isHidden = true
            btnMore.isHidden = false
        }
        else if sender == btnPencil {
            edtingView.isHidden = true
            btnMore.isHidden = false
            completionBlock?(100, data)
        }
        else if sender == btnTrash {
            edtingView.isHidden = true
            btnMore.isHidden = false
            completionBlock?(101, data)
        }
    }
}
class PaymentManagerViewController: BaseViewController {
    @IBOutlet weak var btnPay: SelectedBtn!
    @IBOutlet weak var btnBank: SelectedBtn!
    @IBOutlet weak var btnCard: SelectedBtn!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bgView: UIView!
    var data: JSON!
    var listData:[JSON] = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.layer.cornerRadius = 24
        self.bgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        CNavigationBar.drawBackButton(self, "결재수단 관리", #selector(actionNaviBack))
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tblView.bounds.size.width, height: 24))
        tblView.tableHeaderView = headerView
        
        self.requestPaymentMethodList()
    }
    
    func requestPaymentMethodList() {
        ApiManager.ins.requestRegisteredPaymentMethods { res in
            print("payment method list: \(res)")
            if res.isEmpty == false {
                let group = Dictionary(grouping: res.arrayValue) { (item:JSON) in
                    return item["pay_method_type"].stringValue
                }
                self.data = JSON(group)
                self.btnPay.sendActions(for: .touchUpInside)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }

    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPay {
            btnPay.isSelected = true
            btnBank.isSelected = false
            btnCard.isSelected = false
            
            self.listData = data["HPAY"].arrayValue
            tblView.reloadData()
        }
        else if sender == btnBank {
            btnPay.isSelected = false
            btnBank.isSelected = true
            btnCard.isSelected = false
            
            self.listData = data["BANK"].arrayValue
            tblView.reloadData()
        }
        else if sender == btnCard {
            btnPay.isSelected = false
            btnBank.isSelected = false
            btnCard.isSelected = true
            
            self.listData = data["CARD"].arrayValue
            
            tblView.reloadData()
        }
        
    }
    
}
extension PaymentManagerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentManagerCell.identifier) as? PaymentManagerCell else {
            return UITableViewCell()
        }
        
        let item = listData[indexPath.row]
        cell.configuraionData(item)
        cell.completionBlock = {(_ index: Int, _ selData:JSON?) ->Void in
            print("touchupinside: \(index)")
            
        }
        return cell
    }
    
}
