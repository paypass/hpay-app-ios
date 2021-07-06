//
//  MainNavigationController.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import SideMenu

class MainNavigationController: BaseNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupSideMenu()
        updateMenus()

        self.navigationBar.isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(named: "BlueAndDark")

    }
   
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
//        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: (sceneDelegate.window?.rootViewController?.view)!)
    }
    private func updateMenus() {
        let settings = makeSettings()
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
    }
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        let modes: [SideMenuPresentationStyle] = [.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn]
        return modes[0]
    }
    private func makeSettings() -> SideMenuSettings {
        
        let presentationStyle = selectedPresentationStyle()
        presentationStyle.backgroundColor = UIColor(named: "AccentColor") ?? UIColor.white
        presentationStyle.menuStartAlpha = CGFloat(1.0)
        presentationStyle.menuScaleFactor = CGFloat(1.0)
        presentationStyle.onTopShadowOpacity = 0.3
        presentationStyle.presentingEndAlpha = CGFloat(0.2)
        presentationStyle.presentingScaleFactor = CGFloat(1)

        var settings = SideMenuSettings()
        settings.allowPushOfSameClassTwice = false
        settings.presentationStyle = .menuSlideIn
        settings.menuWidth = min(view.frame.width, view.frame.height) * CGFloat(0.55)
        let styles:[UIBlurEffect.Style?] = [nil, .dark, .light, .extraLight]
        settings.blurEffectStyle = styles[0]
        settings.statusBarEndAlpha = 0

        return settings
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        print("==== willshow ====")
        if viewController.isEqual(viewControllers.first) {
            viewController.navigationController?.tabBarController?.tabBar.isHidden = false
        }
        else {
            viewController.navigationController?.tabBarController?.tabBar.isHidden = true
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        print("==== didshow ====")
        if viewController.isEqual(viewControllers.first) {
            viewController.navigationController?.tabBarController?.tabBar.isHidden = false
        }
        else {
            viewController.navigationController?.tabBarController?.tabBar.isHidden = true
        }
    }

}
