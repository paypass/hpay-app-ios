//
//  MainTabBarController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SideMenu

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        UITabBar.appearance().tintColor = UIColor(named: "AccecntColor")
        UITabBar.appearance().barTintColor = UIColor(named: "WhitAndDark")
        self.hidesBottomBarWhenPushed = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let index = self.viewControllers?.firstIndex(of: viewController)
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let index = self.viewControllers?.firstIndex(of: viewController)
//        print("==== selected tab index: \(String(describing: index))")
    }
}
