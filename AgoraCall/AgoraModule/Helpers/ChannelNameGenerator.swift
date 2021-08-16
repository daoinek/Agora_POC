//
//  ChannelNameGenerator.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 06.08.2021.
//

import Foundation

struct ChannelNameGenerator {
    
    static func get(uId: String, userId: String) -> String {
        return "channel-\(uId)_\(userId)"
    }
}
