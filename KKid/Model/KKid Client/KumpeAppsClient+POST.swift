//
//  KumpeAppsClient+POST.swift
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

// MARK: - POST Methods

// MARK: addChore
    class func addChore(username: String, choreName: String, choreDescription: String, blockDash: Bool, oneTime: Bool, optional: Bool, startDate: Date, day: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "kidUsername": "\(username)",
            "choreName": "\(choreName)",
            "choreDescription": "\(choreDescription)",
            "blockDash": "\(blockDash)",
            "oneTime": "\(oneTime)",
            "day": "\(day)",
            "optional": "\(optional)"
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/chorelist"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
            completion(success, error)
        }
    }

// MARK: addUser
    class func addUser(username: String, email: String, firstName: String, lastName: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "password": password
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/userlist"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
            completion(success, error)
        }
    }

// MARK: addMaster
    class func addMaster(username: String, email: String, firstName: String, lastName: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "password": password
        ]

        let module = "kkid/masteruser"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(appkey)"]) { success, error in
            completion(success, error)
        }
    }

// MARK: addAllowanceTransaction
    class func addAllowanceTransaction(userID: Int, amount: String, description: String, transactionType: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "kidUserId": "\(userID)",
            "amount": amount,
            "description": description,
            "transactionType": transactionType
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/allowance"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
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
            "kidUserId":"\(userID)",
            "token":"\(token)",
            "tool":"register",
            "deviceName":"\(UIDevice.current.name)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(masterID)"
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/apns"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { _, _ in}
    }

// MARK: subscribeAPNS
    class func subscribeAPNS(user: User, section: String) {
        let parameters = [
            "kidUserId":"\(user.userID)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(user.masterID)",
            "section":"\(section)",
            "tool":"subscribe"
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/apns"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { _, _ in}
    }

// MARK: unsubscribeAPNS
    class func unsubscribeAPNS(user: User, section: String) {
        let parameters = [
            "kidUserId":"\(user.userID)",
            "appName":"com.kumpeapps.ios.kkid",
            "masterID":"\(user.masterID)",
            "section":"\(section)",
            "tool":"unsubscribe"
            ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/apns"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { _, _ in}
    }

// MARK: addWish
    class func addWish(userID: String, title: String, description: String = "", priority: Int = 5, link: String = "", completion: @escaping (Bool, String?) -> Void) {
        let parameters = [
            "kidUserId": "\(userID)",
            "title": title,
            "description": description,
            "priority": "\(priority)",
            "link": link
        ]

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/wishlist"
        apiPost(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers: ["X-Auth":"\(authKey)"]) { success, error in
            completion(success, error)
        }
    }

}
