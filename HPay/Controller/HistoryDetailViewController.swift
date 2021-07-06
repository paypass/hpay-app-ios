//
//  HistoryDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit

class HistoryDetailViewController: BaseViewController {

    @IBOutlet weak var btnPay: SelectedBtn!
    @IBOutlet weak var btnBank: SelectedBtn!
    @IBOutlet weak var btnCard: SelectedBtn!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var piChartView: UIView!
    
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 20
        bgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tblView.bounds.size.width, height: 16))
        tblView.tableHeaderView = headerView
        
        btnBank.sendActions(for: .touchUpInside)
        
        CNavigationBar.drawBackButton(self, "결제 내역", #selector(actionNaviBack))
        
        btnPay.sendActions(for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func requestData() {
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnPay {
            btnPay.isSelected = true
            btnBank.isSelected = false
            btnCard.isSelected = false
        }
        else if sender == btnBank {
            btnPay.isSelected = false
            btnBank.isSelected = true
            btnCard.isSelected = false
        }
        else if sender == btnCard {
            btnPay.isSelected = false
            btnBank.isSelected = false
            btnCard.isSelected = true
        }
    }
}

extension HistoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
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
