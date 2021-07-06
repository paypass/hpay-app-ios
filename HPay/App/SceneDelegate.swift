//
//  SceneDelegate.swift
//  HPay
//
//  Created by 김학철 on 2021/06/27.
//

import UIKit
import CoreData
import SwiftyGif

weak var sceneDelegate: SceneDelegate!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var loadingView: UIView?
    
    var mainNavigationCtrl: MainNavigationController!
    
    var currentLanguage: String = "en"
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        sceneDelegate = self
        
        self.window = UIWindow(windowScene: scene)
        self.mainNavigationCtrl = MainNavigationController.instantiateFromStoryboard(.main)!
        self.window?.rootViewController = mainNavigationCtrl
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground")
    }
    
    public func startIndicator() {
        DispatchQueue.main.async(execute: {
            if let loadingView = self.window!.viewWithTag(215000) {
                loadingView.removeFromSuperview()
            }
            
            self.loadingView = UIView(frame: UIScreen.main.bounds)
            self.window!.addSubview(self.loadingView!)
            self.loadingView?.tag = 215000
            self.loadingView?.backgroundColor = RGBA(0, 0, 0, 0.2)
            
//            let ivLoading = UIImageView.init()
            let ivLoading = UIActivityIndicatorView()
            self.loadingView?.addSubview(ivLoading)
            ivLoading.translatesAutoresizingMaskIntoConstraints = false
            
            ivLoading.centerXAnchor.constraint(equalTo: self.loadingView!.centerXAnchor).isActive = true
            ivLoading.centerYAnchor.constraint(equalTo: self.loadingView!.centerYAnchor).isActive = true
            ivLoading.heightAnchor.constraint(equalToConstant: 100).isActive = true
            ivLoading.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            ivLoading.color = UIColor(named: "AccentColor")
            ivLoading.style = .large
            ivLoading.startAnimating()
    
//            do {
//                let gif = try UIImage(gifName: "loading.gif")
//                ivLoading.setGifImage(gif)
//            }
//            catch {
//
//            }
            //혹시라라도 indicator 계속 돌고 있으면 강제로 제거 해준다. 10초후에
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
                if let loadingView = self.window!.viewWithTag(215000) as? UIActivityIndicatorView {
                    loadingView.stopAnimating()
                    loadingView.removeFromSuperview()
                    
                }
            }
        })
    }
    public func stopIndicator() {
        DispatchQueue.main.async(execute: {
            if self.loadingView != nil {
                //                self.loadingView!.stopAnimation()
                self.loadingView?.removeFromSuperview()
            }
        })
    }
    
    //MARK: - CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodayIsYou")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

