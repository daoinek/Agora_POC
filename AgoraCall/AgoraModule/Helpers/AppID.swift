//
//  AppID.swift
//  Agora VideoCall
//
//  Created by Kostya Bershov.
//  Copyright © 2021 Daoinek. All rights reserved.
//

import Foundation

struct Auth {
    static let app_id = "349a1bfcdb5f4cc9b9013040daff5037"
    static var token = "006349a1bfcdb5f4cc9b9013040daff5037IAALNGkiz38SIKJTgabALGKOPz/DLSq144l92SjXB6dQz2lMJ4sAAAAAEACe0CRJkwAUYQEAAQCOABRh"
    
    static var currenUserName: String {
        set { UserDefaults.standard.setValue(newValue, forKey: "currenUserName") }
        get { UserDefaults.standard.value(forKey: "currenUserName") as? String ?? ""}
    }
    
    static var currenUserId: String {
        set { UserDefaults.standard.setValue(newValue, forKey: "currenUserId") }
        get { UserDefaults.standard.value(forKey: "currenUserId") as? String ?? ""}
    }
}


/*
let AppID: String = "daa3fbf82d584684b1752d67a54b6471" // "1ae8ad68b5e746c4a5f33cf0baeadb65"//
var Token: String? =
    "0061ae8ad68b5e746c4a5f33cf0baeadb65IABKbSJCXMRgrU8/qvoJ9dvbeGa25ie9pXgOy2+SGNSB20K0yQsAAAAAEACZZ/Ce+qkTYQEAAQD3qRNh"
//"006349a1bfcdb5f4cc9b9013040daff5037IACUoinfxKysjG2cTXtB6QFE0UFXg1O/wJJtD1XGxhE4jBsAjy0AAAAAEACe0CRJrL8TYQEAAQCovxNh"

//"0061ae8ad68b5e746c4a5f33cf0baeadb65IABKbSJCXMRgrU8/qvoJ9dvbeGa25ie9pXgOy2+SGNSB20K0yQsAAAAAEACZZ/Ce+qkTYQEAAQD3qRNh"
*/
