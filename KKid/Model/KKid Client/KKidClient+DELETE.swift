//
//  KKidClient+DELETE.swift
//  KKid
//
//  Created by Justin Kumpe on 9/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON

extension KKidClient {

// MARK: - DELETE Methods

// MARK: deleteChore
        class func deleteChore(_ idChoreList: Int16, completion: @escaping (Bool, String?) -> Void) {
            let parameters = [
                "apiUsername": KKidClient.username,
                "apiPassword": KKidClient.apiPassword,
                "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
                "idChoreList": "\(idChoreList)"
            ]
            let module = "chorelist"
            apiDelete(silent: true, module: module, parameters: parameters, blockInterface: false) { (success, error) in
                completion(success, error)
            }
        }

// MARK: deleteUser
    class func deleteUser(_ user: User, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "userID": "\(user.userID)"
        ]
        let module = "userlist"
        apiDelete(silent: false, module: module, parameters: parameters, blockInterface: false) { (success, error) in
            completion(success, error)
        }
    }

// MARK: unsubscribeAPNS
    class func unsubscribeAPNS(user: User, section: String) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "kidUserId":"\(user.userID)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(user.masterID)",
            "section":"\(section)",
            "tool":"unsubscribe"
        ]
        apiDelete(silent: true, module: "apns", parameters: parameters) { (_, _) in
        }
    }

// MARK: apiDelete
        class func apiDelete(silent: Bool = false, module: String, parameters: [String: Any], blockInterface: Bool = false, completion: @escaping (Bool, String?) -> Void) {
            apiMethod(silent: silent, method: .delete, module: module, parameters: parameters, blockInterface: blockInterface) { (success, error) in
                completion(success, error)
            }
        }

}
