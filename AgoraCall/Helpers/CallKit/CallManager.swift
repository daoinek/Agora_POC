//
//  CallManager.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import Foundation
import CallKit
import AVFoundation


protocol CallManagerDelegate: class {
    func callManager(_ sender: CallManager, userDidJoin userId: String)
    func callManager(_ sender: CallManager, didReceiveData data: Data)
    func callDidStart(_ sender: CallManager)
    func callDidEnd(_ sender: CallManager)
}


class CallManager: NSObject, CXProviderDelegate {
    static let CallManagerCallStartedNotification = Notification.Name("CallManagerCallStartedNotification")
    static var shared = CallManager()

    fileprivate let provider: CXProvider
    fileprivate let callController: CXCallController
    fileprivate var dataQueue = [Data]()
    fileprivate var isDataChannelOpen = false

    weak var delegate: CallManagerDelegate? {
        didSet {
            if currentCall != nil {
                delegate?.callDidStart(self)
            }
        }
    }
    fileprivate(set) var currentCall: Call?

    fileprivate static var providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Whale")
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]

        return providerConfiguration
    }()

    private override init() {
        provider = CXProvider(configuration: CallManager.providerConfiguration)
        callController = CXCallController()
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    fileprivate func reset() {
        currentCall = nil
      //  currentConnection?.disconnect()
     //   currentConnection = nil
        isDataChannelOpen = false
        dataQueue.removeAll()
    }

    func reportIncomingCall(_ call: Call) {
        currentCall = call
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: call.handle)
        callUpdate.hasVideo = true

        provider.reportNewIncomingCall(
            with: call.uuid,
            update: callUpdate,
            completion: { _ in })
    }

    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        reset()
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let call = currentCall else {
            action.fail()
            reset()
            assertionFailure("Call must be set before call can be started")
            return
        }

        SoundManager.configureAudioSession()
     //   currentConnection?.connect(toUserId: call.partnerId)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let currentCall = currentCall else {
            action.fail()
            reset()
            assertionFailure("Call must be set before call can be answered")
            return
        }
        postCallStartedNotification()
        SoundManager.configureAudioSession()
     //   currentConnection?.answerIncomingCall(userId: currentCall.partnerId)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard currentCall != nil else {
            action.fail()
            reset()
            assertionFailure("Call must be set before call can be ended")
            return
        }
        reset()
        self.delegate?.callDidEnd(self)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print(#function)
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print(#function)
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print(#function)
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
      //  currentConnection?.localAudioTrack?.isEnabled = !action.isMuted
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        fatalError("Not Implemented")
    }

    fileprivate func postCallStartedNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CallManager.CallManagerCallStartedNotification,
                                            object: nil)
        }
    }
}

extension CallManager {
    // MARK: - CXCallController
    func initiate(call: Call) {
        guard currentCall == nil else {
            assertionFailure("There should be no active call for initiation")
            return
        }
        currentCall = call
        let cxhandle = CXHandle(type: .generic, value: call.handle)
        let startCallAction = CXStartCallAction(call: call.uuid, handle: cxhandle)
        startCallAction.isVideo = true
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction, completion: { error in
            if let error = error {
                self.currentCall = nil
                fatalError(error.localizedDescription)
            }
        })
    }

    func end() {
        guard let currentCall = currentCall else {
            return
        }

        let endCallAction = CXEndCallAction(call: currentCall.uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction) { error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }

    fileprivate func requestTransaction(_ transaction: CXTransaction, completion: @escaping (Error?) -> Void) {
        callController.request(transaction) { error in
            completion(error)
            if let error = error {
                print(error)
            }
        }
    }
}
