//
//  CallVC.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import UIKit
import AgoraRtcKit


class CallVC: UIViewController {
    
    
    //MARK: Outlets
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    //MARK:- Variables
    private var viewModel: CallViewModel!
    private var videoIsDisabled = false
    private var timer: Timer?
    private var callTime: Int = 0
    private var remoteUid: UInt = 0
    private var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = viewModel.localVideo, let view = it.view {
                if view.superview == localContainer {
                    remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                    localVideoMutedIndicator.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    private var isLocalVideoRender: Bool = false {
        didSet {
            if let it = viewModel.localVideo, let view = it.view {
                if view.superview == localContainer {
                    localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                    remoteVideoMutedIndicator.isHidden = isLocalVideoRender
                }
            }
        }
    }
    private var isStartCalling: Bool = true {
        didSet {
            if isStartCalling { micButton.isSelected = false }
            videoButton.isHidden = !isStartCalling
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    
    //MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CallViewModel(vc: self)
        viewModel.initializeAgoraEngine()
        viewModel.setupVideo()
        viewModel.setupLocalVideo(in: localContainer)
        joinChannel(withId: "POC")
    }
    
    
    private func joinChannel(withId id: String) {
        viewModel.joinChannel(withId: id) { self.isLocalVideoRender = true }
        isStartCalling = true
        startCallTimer()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    
    private func leaveChannel() {
        timer?.invalidate()
        timer = nil
        viewModel.agoraKit.leaveChannel(nil)
        isRemoteVideoRender = false
        isLocalVideoRender = false
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    private func startCallTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    private func switchView(_ canvas: AgoraRtcVideoCanvas?) {
        let parent = removeFromParent(canvas)
        if parent == localContainer {
            canvas!.view!.frame.size = remoteContainer.frame.size
            remoteContainer.addSubview(canvas!.view!)
        } else if parent == remoteContainer {
            canvas!.view!.frame.size = localContainer.frame.size
            localContainer.addSubview(canvas!.view!)
        }
    }
    
    
    //MARK:- Tergets and Actions
    @objc private func fireTimer() {
        callTime += 1
        timeLabel.text = callTime.secToTime()
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            leaveChannel()
            removeFromParent(viewModel.localVideo)
            viewModel.localVideo = nil
            removeFromParent(viewModel.remoteVideo)
            viewModel.remoteVideo = nil
        } else {
            viewModel.setupLocalVideo(in: localContainer)
            joinChannel(withId: "POC")
        }
    }
    
    
    @IBAction func didClickvideoButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        videoIsDisabled ? viewModel.agoraKit.enableVideo() : viewModel.agoraKit.disableVideo()
        videoIsDisabled = !videoIsDisabled
        isRemoteVideoRender = !videoIsDisabled
        isLocalVideoRender = !videoIsDisabled
    }
    
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        viewModel.agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        viewModel.agoraKit.switchCamera()
    }
    
    @IBAction func didClickLocalContainer(_ sender: Any) {
        switchView(viewModel.localVideo)
        switchView(viewModel.remoteVideo)
    }
}


//MARK:- Agora Delegate Extension
extension CallVC: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoEnabled enabled: Bool, byUid uid: UInt) {
        isRemoteVideoRender = enabled
        isLocalVideoRender = enabled
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        connectionLabel.isHidden = (state == .connected)
    }
    

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        isRemoteVideoRender = true
        var parent: UIView = remoteContainer
        if let it = viewModel.localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        if viewModel.remoteVideo != nil {
            return
        }
        self.remoteUid = uid
        viewModel.rtcEngine(didJoinedOfUid: uid, parent: parent)
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = viewModel.remoteVideo, it.uid == uid {
            removeFromParent(it)
            viewModel.remoteVideo = nil
        }
    }
        
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        connectionLabel.isHidden = isRemoteVideoRender ? (stats.decoderOutputFrameRate > 4) : true
    }

    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        isRemoteVideoRender = !muted
    }
}
