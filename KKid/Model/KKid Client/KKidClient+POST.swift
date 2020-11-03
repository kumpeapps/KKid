//
//  KKidClient+POST.swift
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

// MARK: - POST Methods

// MARK: addChore
    class func addChore(username: String, choreName: String, choreDescription: String, blockDash: Bool, oneTime: Bool, optional: Bool, startDate: Date, day: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "kidUsername": "\(username)",
            "choreName": "\(choreName)",
            "choreDescription": "\(choreDescription)",
            "blockDash": "\(blockDash)",
            "oneTime": "\(oneTime)",
            "day": "\(day)",
            "optional": "\(optional)"
        ]
        let module = "chorelist"
        apiPost(module: module, parameters: parameters) { (success, error) in
            completion(success, error)
        }
    }

// MARK: addUser
    class func addUser(username: String, email: String, firstName: String, lastName: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "password": password
        ]
        let module = "userlist"
        apiPost(module: module, parameters: parameters) { (success, error) in
            completion(success, error)
        }
    }

// MARK: addMaster
    class func addMaster(username: String, email: String, firstName: String, lastName: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "password": password
        ]
        let module = "authentication"
        apiPost(module: module, parameters: parameters, blockInterface: true) { (success, error) in
            completion(success, error)
        }
    }

// MARK: addAllowanceTransaction
    class func addAllowanceTransaction(userID: Int, amount: String, description: String, transactionType: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "kidUserId": "\(userID)",
            "amount": amount,
            "description": description,
            "transactionType": transactionType
        ]
        let module = "allowance"
        apiPost(module: module, parameters: parameters) { (success, error) in
            completion(success, error)
        }
    }

// MARK: registerAPNS
    class func registerAPNS(_ token: String) {
        guard let userID = LoggedInUser.user?.userID else {
            return
        }
        guard let masterID = LoggedInUser.user?.masterID else {
            return
        }
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "kidUserId":"\(userID)",
            "token":"\(token)",
            "tool":"register",
            "deviceName":"\(UIDevice.current.name)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(masterID)"
        ]
        apiPost(silent: true, module: "apns", parameters: parameters) { (success, _) in
            if success {
                guard let user = LoggedInUser.user else {
                    return
                }
                subscribeAPNS(user: user, section: "Main")
            }
        }
    }

// MARK: subscribeAPNS
    class func subscribeAPNS(user: User, section: String) {
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "kidUserId":"\(user.userID)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(user.masterID)",
            "section":"\(section)",
            "tool":"subscribe"
        ]
        apiPost(silent: true, module: "apns", parameters: parameters) { (_, _) in
        }
    }

// MARK: apiPost
    class func apiPost(silent: Bool = false, module: String, parameters: [String: Any], blockInterface: Bool = false, completion: @escaping (Bool, String?) -> Void) {
        apiMethod(silent: silent, method: .post, module: module, parameters: parameters, blockInterface: blockInterface) { (success, error) in
            completion(success, error)
        }
    }

}
