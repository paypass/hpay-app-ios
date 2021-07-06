//
//  HomeViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SideMenu
import SwiftyJSON
import Toast_Swift

class HomeViewController: BaseViewController {
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    var listData: [JSON] = [JSON]()
    var headerView: HistoryHeaderView!
    var footerView: HistoryFooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cornerView.layer.cornerRadius = 20
        cornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        cardView.layer.cornerRadius = 16
        cardView.addShadow(offset: CGSize(width: 5, height: -5), color: RGBA(0, 0, 0, 0.3), raduius: 5, opacity: 0.3)
    
        self.configUi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigation()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func setNavigation() {
        CNavigationBar.drawLeftBarItem(self, "list.bullet", nil, TAG_NAVI_MEMU, #selector(actionNaviMenu))
        let attr = NSAttributedString.init(string: "12,000", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .black)])
        CNavigationBar.drawTitle(self, attr, nil)
        CNavigationBar.drawRight(self, "bell.badge", nil, TAG_NAVI_BELL, #selector(actionNaviBell))
    }
    func configUi() {
        self.headerView = Bundle.main.loadNibNamed("HistoryHeaderView", owner: nil, options: nil)?.first as? HistoryHeaderView
        tblView.tableHeaderView = headerView
        
        headerView.completion = { index in
            var sortType: String?
            if index == 100 {
                sortType = "시간"
            }
            else if index == 200 {
                sortType = "금액"
            }
            else if index == 300 {
                sortType = "입금"
            }
            else if index == 400 {
                sortType = "출금"
            }
            else if index == 500 {
                let vc = HistoryDetailViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            guard let sortType = sortType else {
                return
            }
            print(sortType)
            self.view.makeToast("\(sortType) 정렬 선택")
        }
        
        let footerView = Bundle.main.loadNibNamed("HistoryFooterView", owner: nil, options: nil)?.first as! HistoryFooterView
        self.tblView.tableFooterView = footerView
        footerView.completion = {(index :Int) in
            if index == 100 {
                self.view.makeToast("더보기 리스트 뷰")
                let vc = HistoryDetailViewController.instantiateFromStoryboard(.main)!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10// listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell
        if  cell == nil {
            cell = Bundle.main.loadNibNamed("HistoryCell", owner: self, options: nil)?.first as? HistoryCell
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
