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
    func requestAddPaymentMethod(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/hpay-wallet/paymethod", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///등록된 결제수단 목록
    func requestRegisteredPaymentMethods(success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/hpay-app/paymethod/1", nil) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
}