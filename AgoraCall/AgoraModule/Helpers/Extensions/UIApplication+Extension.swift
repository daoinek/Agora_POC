//
//  UIApplication+Extension.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 08.08.2021.
//

import UIKit


extension UIApplication {
    
    class func getTopVC() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
