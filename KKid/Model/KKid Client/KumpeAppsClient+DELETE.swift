//
//  KumpeAppsClient+DELETE.swift
//  KKid
//
//  Created by Justin Kumpe on 10/22/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON

extension KumpeAppsClient {

// MARK: - DELETE Methods

// MARK: deleteChore
        class func deleteChore(_ idChoreList: Int16, completion: @escaping (Bool, String?) -> Void) {
            let parameters = [
                "idChoreList": "\(idChoreList)"
            ]

            let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
            let module = "kkid/chorelist"
            apiDelete(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
                completion(success,error)
            }
        }

// MARK: deleteUser
    class func deleteUser(_ user: User, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "userID": "\(user.userID)"
        ]
        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/userlist"
        apiDelete(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
            completion(success,error)
        }
    }
}
