//
//  ApiManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/09.
//

import UIKit
import Foundation
import Alamofire

class ApiManager: NSObject {
    static let ins = ApiManager()
    //!메인
    func requestMain(success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/hpay-app/main/1", nil) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }

    /**
     결제 수단 추가
     - paramter:
     1. method_type : "CARD"
     2. method_code : "099"
     3. wallet_id : 19
     4. method_name : "shinhanbank"
     5. method_info : "xxxx-xx-xxxx-9777"
     6. verify_code : "388833"
     */
    func requestRegistPaymentMethod(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/hpay-wallet/paymethod", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///등록된 결제수단 목록
    func requestRegisteredPaymentMethods(success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/hpay-app/pay_method/1", nil) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///등록가능한 결제수단 목록
    func requestRegistAvailablePayment(method:String, success:ResSuccess?, fail:ResFailure?) {
        let url = "/hpay-wallet/providers?pay_method_type=\(method)"
        NetworkManager.ins.request(.get, url, nil) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///충전
    func requestChargeHPay(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/hpay-wallet/charge", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    //상품 결제
    func requestProductPayment(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/hpay-payment/payment", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
}
