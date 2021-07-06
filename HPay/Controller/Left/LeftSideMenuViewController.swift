//
//  LeftSideMenuViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SideMenu

class LeftSideMenuViewController: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var listData = [
        ["cell_id":"addPayment", "title":"결재수단 추가", "image":"creditcard.fill"],
        ["cell_id":"paymentManager", "title":"결재수단 관리", "image":"plus.rectangle.fill.on.folder.fill"],
        ["cell_id":"login", "title":"로그인", "image":"arrow.forward.square"],
        ["cell_id":"logout", "title":"로그아웃", "image":"arrow.backward.square"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableHeaderView = headerView
        tblView.tableFooterView = UIView()
        
        self.view.addGradient(UIColor(named: "BlueAndDark"), end: UIColor.white, sPoint: CGPoint(x: 1, y:0), ePoint: CGPoint(x: 1, y: 1))
        
        headerView.clipsToBounds = true
        self.headerView.backgroundColor = UIColor.clear
        tblView.backgroundColor = UIColor.clear
        
    }
}
extension LeftSideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftSideMenuCell") as? LeftSideMenuCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        let data = listData[indexPath.row]
        cell.configurationData(data)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = listData[indexPath.row]
        let cellId = item["cell_id"]
        
        if cellId == "addPayment" {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            left.dismiss(animated: true) {
                let vc = AddPaymentViewController.instantiateFromStoryboard(.main)!
                sceneDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
        }
        else if cellId == "paymentManager" {
            guard let left = SideMenuManager.default.leftMenuNavigationController else { return }
            left.dismiss(animated: true) {
                let vc = PaymentManagerViewController.instantiateFromStoryboard(.main)!
                sceneDelegate.mainNavigationCtrl.pushViewController(vc, animated: true)
            }
        }
    }
}

class LeftSideMenuCell: UITableViewCell {
    @IBOutlet var ivIcon: UIImageView!
    @IBOutlet var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configurationData(_ data:[String:Any]) {
        let imgName = data["image"] as! String
        let title = data["title"] as! String
        ivIcon.image = UIImage(systemName: imgName)
        lbTitle.text = title
    }
}
