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
    @IBOutlet weak var cardView: FSPagerView!
    @IBOutlet weak var tblView: UITableView!
    
    var listData: [JSON] = [JSON]()
    var headerView: HistoryHeaderView!
    var footerView: HistoryFooterView!
    
    var payments:[JSON] = [JSON]()
    var balance: NSNumber = NSNumber.init(integerLiteral: 0)
    var selPayment: JSON = [] {
        didSet {
            self.tblView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cornerView.layer.cornerRadius = 20
        cornerView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        cardView.layer.cornerRadius = 16
        cardView.addShadow(offset: CGSize(width: 5, height: -5), color: RGBA(0, 0, 0, 0.3), raduius: 5, opacity: 0.3)
        self.setHeaderView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigation()
        self.requestMainData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func requestMainData() {
        ApiManager.ins.requestMain { res in
            if res.isEmpty == false {
                self.payments = res["main_transaction"].arrayValue
                self.balance = res["total_balance"].numberValue
                self.decorationUi()
                ShareData.ins.walletId = res["wallet_id"].stringValue
                ShareData.ins.walletName = res["wallet_name"].stringValue
            }
            else {
                self.showErrorToast(res)
            }
        } fail: { error in
            self.showErrorToast(error)
        }
    }
    func setNavigation() {
        CNavigationBar.drawLeftBarItem(self, "list.bullet", nil, TAG_NAVI_MEMU, #selector(actionNaviMenu))
        let attr = NSAttributedString.init(string: "₩0", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .black)])
        CNavigationBar.drawTitle(self, attr, nil)
        CNavigationBar.drawRight(self, "bell.badge", nil, TAG_NAVI_BELL, #selector(actionNaviBell))
    }
    func setHeaderView() {
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
        
//        let footerView = Bundle.main.loadNibNamed("HistoryFooterView", owner: nil, options: nil)?.first as! HistoryFooterView
//        self.tblView.tableFooterView = footerView
//        footerView.completion = {(index :Int) in
//            if index == 100 {
//                self.view.makeToast("더보기 리스트 뷰")
//                let vc = HistoryDetailViewController.instantiateFromStoryboard(.main)!
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
        
        cardView.register(UINib(nibName: "CardPagerCell", bundle: nil), forCellWithReuseIdentifier: "CardPagerCell")
//        pagerView.automaticSlidingInterval = 3.0
//        pagerView.isInfinite = true
//        pagerView.decelerationDistance = FSPagerView.automaticDistance
        cardView.transformer = FSPagerViewTransformer(type: .depth)
//        pagerView.transformer?.minimumScale = 0.85
        cardView.interitemSpacing = 0
        cardView.scrollDirection = .vertical
      
        let scale = CGFloat(1.0)
        let itemSize = cardView.frame.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        cardView.itemSize = itemSize
        
        cardView.delegate = self
        cardView.dataSource = self
    }
    func decorationUi() {
        cardView.reloadData()
        let amountStr = (balance.stringValue).addComma()
        let attr = NSAttributedString.init(string: "₩\(amountStr)", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 20, weight: .black)])
        CNavigationBar.drawTitle(self, attr, nil)
    
        guard payments.isEmpty == false else {
            return
        }
        
        self.selPayment = payments[0]
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let transactions = selPayment["transactions"].arrayValue
        return  transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell
        if  cell == nil {
            cell = Bundle.main.loadNibNamed("HistoryCell", owner: self, options: nil)?.first as? HistoryCell
        }
        let transactions = selPayment["transactions"].arrayValue
        let item = transactions[indexPath.row]
        cell?.configurationData(data: item)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
extension HomeViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return payments.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "CardPagerCell", at: index) as! CardPagerCell
        let item = payments[index]
        cell.configurationData(item, index)
        return cell
    }
//    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int) {
//        print("didEndDisplaying: \(index)")
//    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        print("willdragging: \(targetIndex)")
        self.selPayment = payments[targetIndex]
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
    }
}
