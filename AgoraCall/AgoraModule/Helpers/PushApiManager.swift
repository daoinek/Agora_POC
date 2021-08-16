//
//  PushApiManager.swift
//  AgoraCall
//
//  Created by Kostya Bershov on 06.08.2021.
//

import Foundation
import Alamofire


fileprivate enum PushApiRequest {
    case signIn,
         signOut(deviceId: String),
         users,
         startCall(uId: String, user: String),
         endCall(callId: String),
         token(userId: String, roomId: String)
    
    
    var baseUrl: String { return "http://ec2-35-74-240-0.ap-northeast-1.compute.amazonaws.com:8082" }
    
    
    var method: HTTPMethod {
        switch self {
        case .signIn, .signOut, .startCall:
            return .post
        case .users, .token:
            return .get
        case .endCall:
            return .put
        }
    }
    
    
    var route: String {
        switch self {
        case .signIn:
            return "/api/account/signin"
        case .signOut(let deviceId):
            return "/api/account/signout/\(deviceId)"
        case .users:
            return "/api/account/list-users"
        case .startCall(let uId, let user):
            return "/api/account/start-call/\(uId)/\(user)"
        case .endCall(let callId):
            return "/api/account/end-call/\(callId)"
        case .token(let userId, let roomId):
            return "/api/account/token/\(userId)/\(roomId)"
        }
    }
    
    
    var headers: HTTPHeaders {
        return ["Content-Type": "application/json"]
    }

    
    func request(withBody body: [String: Any], _ result: @escaping(Result<Any, AFError>) -> Void) {
        if method == .get {
            AF.request(baseUrl + route,
                       method: method,
                       headers: headers).responseJSON { response in
                        print(response.debugDescription)
                        result(response.result)
            }
            return
        }
        AF.request(baseUrl + route,
                   method: method,
                   parameters: body,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    print(response.debugDescription)
                    result(response.result)
        }
    }
}


struct PushApiManager {
    
    static func signIn(name: String, deviceToken: String, deviceId: String, _ callback: @escaping(Int?) -> Void) {
        PushApiRequest.signIn.request(withBody: ["name": name,
                                                 "DeviceToken": deviceToken,
                                                 "DeviceId": deviceId,
                                                 "Platform": 0]) { result in
            switch result {
            case .failure:
                callback(nil)
            case .success(let anyData):
                callback(anyData as? Int)
            }
        }
    }
    
    
    static func startCall(uId: String, user: String, _ callback: @escaping(Int?) -> Void) {
        PushApiRequest.startCall(uId: uId, user: user).request(withBody: [:]) { result in
            switch result {
            case .failure:
                callback(nil)
            case .success(let anyData):
                callback(anyData as? Int)
            }
        }
    }
    
    
    static func endCall(withId id: Int) {
        PushApiRequest.endCall(callId: "\(id)").request(withBody: [:]) { result in
            print("call ended")
        }
    }
    
    static func getCallToken(_ user: String, room: String,  _ callback: @escaping(String?) -> Void) {
        PushApiRequest.token(userId: user, roomId: room).request(withBody: [:]) { result in
            switch result {
            case .failure:
                callback(nil)
            case .success(let anyData):
                callback(anyData as? String)
            }
        }
    }
}
