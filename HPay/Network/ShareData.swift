//
//  ShareData.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit
import SwiftyJSON

class ShareData: NSObject {
    static let ins = ShareData()
    var walletId: String = ""
    var walletName: String = ""
    
    func dfsSet(_ value: Any?, _ key: String?) {
        guard let key = key, let value = value  else {
            return
        }
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    func dfsGet(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    func dfsRemove(_ key:String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
}
