//
//  HistoryDetailViewController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/29.
//

import UIKit
import SwiftyJSON
import Charts

class HistoryDetailViewController: BaseViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var chartView: PieChartView!
    
    @IBOutlet weak var tblView: UITableView!
    var payment: JSON!
    var transaction = [JSON]()
    var paymentMethodType:String!
    var totoalAmount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.cornerRadius = 20
        bgView.layer.maskedCorners = CACornerMask(TL: true, TR: true, BL: false, BR: false)
        
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.tblView.bounds.size.width, height: 16))
        tblView.tableHeaderView = headerView
        
        CNavigationBar.drawBackButton(self, "결제 내역", #selector(actionNaviBack))
        self.setupPieChartView(chartView)
        chartView.delegate = self
        let l = chartView.legend;
        l.horizontalAlignment = .right;
        l.verticalAlignment = .top;
        l.orientation = .vertical;
        l.drawInside = false;
        l.xEntrySpace = 7.0;
        l.yEntrySpace = 0.0;
        l.yOffset = 0.0;
        
        // entry label styling
        chartView.entryLabelColor = .black;
        chartView.entryLabelFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        self.requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func requestData() {
        var param = [String:Any]()
        param["pay_method_type"] = self.payment["pay_method_type"].stringValue
        param["pay_method_id"] = self.payment["pay_method_id"].intValue
    
        param["size"] = 20
        ApiManager.ins.requestPaymentDetailTransaction(param: param) { res in
            if res.isEmpty == false {
                self.totoalAmount = res["total_amount"].intValue
                self.paymentMethodType = res["pay_method_type"].stringValue
                self.transaction = res["transaction"].arrayValue
                    
                self.setPichartData()
                self.tblView.reloadData()
            }
            
        } fail: { error in
            self.showErrorToast(error)
        }

    }
    func setupPieChartView(_ chardView: PieChartView) {
        chardView.usePercentValuesEnabled = false
        chardView.drawSlicesUnderHoleEnabled = false
        chardView.holeRadiusPercent = 0.58
        chardView.transparentCircleRadiusPercent = 0.61
        chardView.chartDescription?.enabled = false
        chardView.setExtraOffsets(left: 5.0, top: 10.0, right: 5.0, bottom: 5.0)
        
        chardView.drawCenterTextEnabled = true
        chardView.centerText = self.payment["pay_method_type"].stringValue
        chardView.drawHoleEnabled = true
        chardView.rotationAngle = 0.0
        chardView.rotationEnabled = true
        chardView.highlightPerTapEnabled = true
        
    }
    
    func setPichartData() {
//        "transaction_type" : "CHARGE",
//        "transaction_date" : "2021-06-12",
//        "shop_name" : "hanpass",
//        "amount" : 100000
        guard transaction.isEmpty == false else {
            return
        }
        
        let group = Dictionary(grouping: transaction) { (item:JSON) in
            return item["shop_name"].stringValue
        }
        
        var entries = [PieChartDataEntry]()
        for item in group {
            var totoal = 0
            for data in item.value {
                let amount = data["amount"].intValue
                totoal += amount
            }
            
            let entry = PieChartDataEntry(value: Double(totoal), label: item.key)
            entries.append(entry)
        }
        
        let dataSet = PieChartDataSet.init(entries: entries, label: self.payment["pay_method_type"].stringValue)
        dataSet.drawIconsEnabled = false
        dataSet.sliceSpace = 2.0
        dataSet.iconsOffset = CGPoint(x: 0, y: 40)
        
        var colors = [NSUIColor]()
        colors.append(contentsOf: ChartColorTemplates.vordiplom())
        colors.append(contentsOf: ChartColorTemplates.joyful())
        colors.append(contentsOf: ChartColorTemplates.colorful())
        colors.append(contentsOf: ChartColorTemplates.liberty())
        colors.append(contentsOf: ChartColorTemplates.pastel())
        colors.append(UIColor(red: 51.0/255, green: 181.0/255, blue: 229/255, alpha: 1))
        
        let pf = NumberFormatter.init()
        pf.numberStyle = .currency
        pf.maximumFractionDigits = 1
        pf.multiplier = 1
        pf.currencySymbol = "₩"
        
        let chatData = PieChartData.init(dataSet: dataSet)
        chatData.setValueFormatter(DefaultValueFormatter.init(formatter: pf))
        chatData.setValueTextColor(.secondaryLabel)
        chatData.setValueFont(UIFont.systemFont(ofSize: 11, weight: .medium))
        chartView.data = chatData
        chartView.highlightValues(nil)
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
   
    }
}

extension HistoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transaction.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell
        if  cell == nil {
            cell = Bundle.main.loadNibNamed("HistoryCell", owner: self, options: nil)?.first as? HistoryCell
        }
        let item = transaction[indexPath.row]
        cell?.configurationData(data: item)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HistoryDetailViewController: ChartViewDelegate {
    
}
