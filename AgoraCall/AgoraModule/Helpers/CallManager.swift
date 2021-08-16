//
//  CallManager.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import PushKit

// curl -v -d '{"aps": {"alert":{"title":"hello"}},"name": "IOSUser2","channel":"channel-2_1"}' --http2 --cert agora_voip.pem:021102 https://api.development.push.apple.com/3/device/3eb6322088f3ff675591b414578e850c7b55b4fd30a6dcb47f75836185af2c17


class CallManager: NSObject, CXProviderDelegate {
    
    static let shared = CallManager()
    
    private var provider: CXProvider?
    private var currentCall: UUID?
    private let callController = CXCallController()
    private var channel = ""
    
    var callId: Int?
    
    func newIncomingCall(user: String, channel: String) {
        self.currentCall = UUID()
        self.channel = channel
        let config = CXProviderConfiguration(localizedName: "Agora Call")
        config.includesCallsInRecents = true
        provider = CXProvider(configuration: config)
        provider?.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: user)
        update.hasVideo = true
        update.localizedCallerName = user
        provider?.reportNewIncomingCall(with: currentCall ?? UUID(), update: update, completion: { error in })
    }
    
    
    func incomingCallIsUnanswered(user: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Missed Call ☎️"
        content.body = "You have a missed call from \(user)"
        content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "calls.notification"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let identifier = "\(user) call \(UIApplication.shared.applicationIconBadgeNumber)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
                return
            }
        }
        provider?.reportCall(with: currentCall ?? UUID(), endedAt: Date(), reason: .unanswered)
        currentCall = nil
    }
    
    
    func endIncomingCall() {
        let callController = CXCallController()
        let endCallAction = CXEndCallAction(call: currentCall ?? UUID())
        callController.request(
            CXTransaction(action: endCallAction),
            completion: { error in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    print("Success")
                }
            })
        provider?.reportCall(with: currentCall ?? UUID(), endedAt: Date(), reason: .remoteEnded)
        currentCall = nil
    }

    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        if let vc = UIApplication.getTopVC() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateViewController(identifier: "CallVC") as? CallVC else { return }
            controller.channelName = channel
            controller.modalPresentationStyle = .fullScreen
            vc.present(controller, animated: true, completion: nil)
            return
        }
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let id = UIDevice.current.identifierForVendor?.uuidString else { return }
        selectUser { user in
            Auth.currenUserName = user
            PushApiManager.signIn(name: user, deviceToken: pushCredentials.token.hexString, deviceId: id) { id in
                if id == nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: nil, message: "Ошибка обращения к серверу. Возможно, вы не используете VPN", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                        if let vc = UIApplication.getTopVC() {
                            vc.present(alert, animated: true, completion: nil)
                            return
                        }
                    }
                    return
                }
                Auth.currenUserId = "\(id ?? 0)"
            }
        }
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let dictionary = payload.dictionaryPayload
        print("push: \(dictionary)")
        let channel = dictionary["channelId"] as? String ?? ""
        let name = dictionary["userName"] as? String ?? "User"
        
        if currentCall != nil {
            self.incomingCallIsUnanswered(user: name)
            completion()
            return
        }
        
        self.newIncomingCall(user: name, channel: channel)
        completion()
    }
    
    
    private func selectUser(_ selectedUser: @escaping(String) -> Void) {
        let alert = UIAlertController(title: "Select User", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "IOSUser1", style: .default, handler: { _ in
            selectedUser("IOSUser1")
        }))
        alert.addAction(UIAlertAction(title: "IOSUser3", style: .default, handler: { _ in
            selectedUser("IOSUser3")
        }))
        if let vc = UIApplication.getTopVC() {
            vc.present(alert, animated: true, completion: nil)
            return
        }
        selectedUser("IOSUser1")
    }
}
