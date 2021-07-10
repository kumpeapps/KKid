//
//  KKidClient+PUT.swift
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

    // MARK: - PUT Methods

        // MARK: markChore
        class func markChore(silent: Bool = false, chore: Chore, choreStatus: String, user: User, completion: @escaping (Bool) -> Void) {

                var parameters: [String: Any] = [
                    "apiUsername": KKidClient.username,
                    "apiPassword": KKidClient.apiPassword,
                    "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
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

                let module = "chorelist"
                apiPut(silent: silent, module: module, parameters: parameters) { (success, error) in
                    completion(success)
                    if !success {
                        Logger.log(.error, "markChore: \(error ?? "An Unknown Error Occurred")")
                    }
                }
            }

// MARK: updateUser
    class func updateUser(username: String, email: String, firstName: String, lastName: String, user: User, emoji: String, enableAllowance: Bool, enableChores: Bool, enableAdmin: Bool, enableTmdb: Bool, tmdbKey: String?, pushChoresNew: Bool = true, pushChoresReminders: Bool = true, pushAllowanceNew: Bool = true, completion: @escaping (Bool, String?) -> Void) {
        var parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "username": username,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "emoji": emoji,
            "userID": "\(user.userID)",
            "enableAllowance": "noChange",
            "enableChores": "noChange",
            "enableAdmin": "noChange"
        ]

        if tmdbKey != nil {
            parameters["tmdbKey"] = tmdbKey
        }

        if enableChores != user.enableChores {
            parameters.updateValue("\(enableChores)", forKey: "enableChores")
        }

        if enableAllowance != user.enableAllowance {
            parameters.updateValue("\(enableAllowance)", forKey: "enableAllowance")
        }

        if enableAdmin != user.isAdmin {
            parameters.updateValue("\(enableAdmin)", forKey: "enableAdmin")
        }

        if enableTmdb != user.enableTmdb {
            parameters["enableTmdb"] = "\(enableTmdb)"
        }

        let module = "userlist"
        apiPut(module: module, parameters: parameters, blockInterface: true) { (success, error) in
            if success {
                updatePushNotifications(user: user, pushChoresNew: pushChoresNew, pushChoresReminders: pushChoresReminders, pushAllowanceNew: pushAllowanceNew)
            }
            completion(success, error)
        }
    }

    // MARK: updatePushNotifications
    class func updatePushNotifications(user: User, pushChoresNew: Bool, pushChoresReminders: Bool, pushAllowanceNew: Bool) {
        if user.pushChoresNew != pushChoresNew {
            switch pushChoresNew {
            case false:
                unsubscribeAPNS(user: user, section: "Chores-New")
            default:
                subscribeAPNS(user: user, section: "Chores-New")
            }
        }

        if user.pushChoresReminders != pushChoresReminders {
            switch pushChoresReminders {
            case false:
                unsubscribeAPNS(user: user, section: "Chores-Reminders")
            default:
                subscribeAPNS(user: user, section: "Chores-Remidners")
            }
        }

        if user.pushAllowanceNew != pushAllowanceNew {
            switch pushAllowanceNew {
            case false:
                unsubscribeAPNS(user: user, section: "Allowance-New")
            default:
                subscribeAPNS(user: user, section: "Allowance-New")
            }
        }
    }

    // MARK: apiPut
        class func apiPut(silent: Bool = false, module: String, parameters: [String: Any], blockInterface: Bool = false, completion: @escaping (Bool, String?) -> Void) {
            apiMethod(silent: silent, method: .put, module: module, parameters: parameters, blockInterface: blockInterface) { (success, error) in
                completion(success, error)
            }
        }

}
