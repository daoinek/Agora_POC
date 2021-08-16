//
//  AppDelegate.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 23.07.2021.
//

import UIKit
import PushKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var voipRegistry: PKPushRegistry!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     /*   PushApiManager.signIn(name: "IOSUser3",
                              deviceToken: "3eb6322088f1ff375591b914578e850c7b55b4fd30a6dcb47f75836185af2c17",
                              deviceId: "F8EB2A16-C41F-49D0-A483-FD59E55R681F") { id in
        }
        Auth.currenUserName = "IOSUser3"
        Auth.currenUserId = "\(3)" */
        registerPush()
        return true
    }

    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }

}

