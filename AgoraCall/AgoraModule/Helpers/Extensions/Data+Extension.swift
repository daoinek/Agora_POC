//
//  Data+Extension.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 08.08.2021.
//

import Foundation


extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
