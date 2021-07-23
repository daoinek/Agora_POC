//
//  SoundManager.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import AVFoundation

struct SoundManager {
    static func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .videoChat)
            try session.setPreferredIOBufferDuration(0.005)
            try session.setPreferredSampleRate(4_410)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func routeAudioToSpeaker() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playAndRecord,
            mode: .videoChat,
            options: [.defaultToSpeaker, .allowBluetooth])
    }
}
