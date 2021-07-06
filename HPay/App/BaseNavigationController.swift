//
//  BaseNavigationController.swift
//  HPay
//
//  Created by 김학철 on 2021/07/02.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(named: "BlueAndDark")
        
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }
        return true
    }
}
