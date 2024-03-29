//
//  KumpeAppsClient+PUT.swift
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

    // MARK: - PUT Methods

// MARK: markChore
    class func markChore(silent: Bool = false, chore: Chore, choreStatus: String, user: User, completion: @escaping (Bool) -> Void) {

        var parameters: [String: Any] = [
            "kidUsername":"\(user.username!)",
            "idChoreList": "\(chore.id)",
            "notes": "\(appVersion)",
            "status": choreStatus,
            "stolenBy": ""
        ]

        if chore.optional && choreStatus == "check" {
            parameters.updateValue("oCheck", forKey: "status")
            parameters.updateValue("\(user.username!)", forKey: "stolenBy")
        }

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/chorelist"
        apiPut(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers:["X-Auth":"\(authKey)"]) { success, error, _ in
            completion(success)
            if !success {
                Logger.log(.error, "markChore: \(error ?? "An Unknown Error Occurred")")
            }
        }
    }

// MARK: updateUser
    class func updateUser(username: String, email: String, firstName: String, lastName: String, user: User, emoji: String, enableAllowance: Bool, enableWishList: Bool, enableChores: Bool, enableAdmin: Bool, enableTmdb: Bool, tmdbKey: String?, pushChoresNew: Bool = true, pushChoresReminders: Bool = true, pushAllowanceNew: Bool = true, completion: @escaping (Bool, String?) -> Void) {
        var parameters = [
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "emoji": emoji,
            "userID": "\(user.userID)"
        ]

        if tmdbKey != nil {
            parameters["tmdbKey"] = tmdbKey
        }

        if enableWishList != user.enableWishList {
            parameters["enableWishList"] = "\(enableWishList)"
        }

        if enableChores != user.enableChores {
            parameters["enableChores"] = "\(enableChores)"
        }

        if enableAllowance != user.enableAllowance {
            parameters["enableAllowance"] = "\(enableAllowance)"
        }

        if enableAdmin != user.isAdmin {
            parameters["enableAdmin"] = "\(enableAdmin)"
        }

        if enableTmdb != user.enableTmdb {
            parameters["enableTmdb"] = "\(enableTmdb)"
        }

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/userlist"
        apiPut(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers:["X-Auth":"\(authKey)"]) { success, error, _ in
            if success {
                updatePushNotifications(user: user, pushChoresNew: pushChoresNew, pushChoresReminders: pushChoresReminders, pushAllowanceNew: pushAllowanceNew)
            } else {
                Logger.log(.error, "updateUser: \(error ?? "An Unknown Error Occurred")")
            }
            completion(success,error)
        }
    }

    // MARK: updatePushNotifications
    class func updatePushNotifications(user: User, pushChoresNew: Bool, pushChoresReminders: Bool, pushAllowanceNew: Bool) {
        if user.pushChoresNew != pushChoresNew {
            switch pushChoresNew {
            case false:
                KumpeAppsClient.unsubscribeAPNS(user: user, section: "Chores-New")
            default:
                KumpeAppsClient.subscribeAPNS(user: user, section: "Chores-New")
            }
        }

        if user.pushChoresReminders != pushChoresReminders {
            switch pushChoresReminders {
            case false:
                KumpeAppsClient.unsubscribeAPNS(user: user, section: "Chores-Reminders")
            default:
                KumpeAppsClient.subscribeAPNS(user: user, section: "Chores-Reminders")
            }
        }

        if user.pushAllowanceNew != pushAllowanceNew {
            switch pushAllowanceNew {
            case false:
                KumpeAppsClient.unsubscribeAPNS(user: user, section: "Allowance-New")
            default:
                KumpeAppsClient.subscribeAPNS(user: user, section: "Allowance-New")
            }
        }
    }

    // MARK: updateWish
    class func updateWish(silent: Bool = false, wish: Wish, user: User, title: String, description: String, priority: Int, link: String, completion: @escaping (Bool) -> Void) {

        var parameters: [String: Any] = [
            "kidUsername":"\(user.username!)",
            "wishId": "\(wish.id)"
        ]

        if title != wish.wishTitle {
            parameters["title"] = title
        }

        if description != wish.wishDescription {
            parameters["description"] = description
        }

        if priority != wish.priority {
            parameters["priority"] = priority
        }

        if link != wish.link {
            parameters["link"] = link
        }

        let authKey = UserDefaults.standard.value(forKey: "apiKey") ?? "null"
        let module = "kkid/wishlist"
        apiPut(apiUrl: "\(baseURL)/\(module)", parameters: parameters, headers:["X-Auth":"\(authKey)"]) { success, error, _ in
            completion(success)
            if !success {
                Logger.log(.error, "markChore: \(error ?? "An Unknown Error Occurred")")
            }
        }
    }
}
