//
//  AppDelegate+Extension.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 10.08.2021.
//

import UIKit
import UserNotifications
import PushKit


extension AppDelegate: UNUserNotificationCenterDelegate, PKPushRegistryDelegate {
    
    func registerPush() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
            if (error == nil) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.registerForVoIPPushes()
                }
            }
        })
    }
    
    
    private func registerForVoIPPushes() {
        // var voipRegistry: PKPushRegistry!
        voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        CallManager.shared.pushRegistry(registry, didUpdate: pushCredentials, for: type)
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        CallManager.shared.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completion: completion)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    }
}
