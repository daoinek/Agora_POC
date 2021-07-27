//
//  CallViewModel.swift
//  AgoraVideoCall
//
//  Created by Kostya Bershov on 23.07.2021.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import UIKit
import AgoraRtcKit


class CallViewModel: NSObject {
    
    private var vc: UIViewController!
    
    var agoraKit: AgoraRtcEngineKit!
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: vc as? AgoraRtcEngineDelegate)
    }
    
    func setupVideo() {
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                             frameRate: .fps15,
                                                                             bitrate: AgoraVideoBitrateStandard,
                                                                             orientationMode: .adaptative))
    }
    
    func setupLocalVideo(in localContainer: UIView) {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: localContainer.frame.size))
        localVideo = AgoraRtcVideoCanvas()
        localVideo?.view = view
        localVideo?.renderMode = .hidden
        localVideo?.uid = 0
        if let localView = localVideo?.view {
            localContainer.addSubview(localView)
            agoraKit.setupLocalVideo(localVideo)
            agoraKit.startPreview()
        }
    }
    
    
    func joinChannel(withId channelId: String, _ callback:@escaping() -> Void) {
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        agoraKit.joinChannel(byToken: Token, channelId: channelId, info: nil, uid: 0) { (channel, uid, elapsed) -> Void in
            callback()
        }
    }
}


extension CallViewModel {
    
    func rtcEngine(didJoinedOfUid uid: UInt, parent: UIView) {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo?.view = view
        remoteVideo?.renderMode = .hidden
        remoteVideo?.uid = uid
        if let remoteView = remoteVideo?.view, let remote = remoteVideo {
            parent.addSubview(remoteView)
            agoraKit.setupRemoteVideo(remote)
        }
    }
}
