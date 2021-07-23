//
//  Int+Extension.swift
//  AgoraVideoCall
//
//  Created by Kostya Bershov on 23.07.2021.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import Foundation


extension Int {
    func secToTime() -> String {
        let min = (self % 3600) / 60
        let sec = (self % 3600) % 60
        
        let string_m = min < 10 ? "0\(min)" : "\(min)"
        let string_s = sec < 10 ? "0\(sec)" : "\(sec)"
        
        return "\(string_m):\(string_s)"
    }
}
