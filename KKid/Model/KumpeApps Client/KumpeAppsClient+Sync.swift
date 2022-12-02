//
//  KumpeAppsClient+Sync.swift
//  KKid
//
//  Created by Justin Kumpe on 10/22/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation

import Alamofire
import Alamofire_SwiftyJSON
import Sync
import CoreData
import KumpeHelpers

extension KumpeAppsClient {

    // MARK: - API to CoreData Syncs

    // MARK: getUsers
        class func getUsers(silent: Bool = false, completion: @escaping (Bool, String?) -> Void) {

            let module = "kkid/userlist"
            let jsonArrayName = "user"
            let coreDataEntityName = "User"
            apiSync(silent: silent, parameters: [:], module: module, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName) { (success, error) in
                completion(success, error)
                NotificationCenter.default.post(name: .isAuthenticated, object: nil)
                LoggedInUser.setLoggedInUser()
            }
        }

    // MARK: getChores
        class func getChores(silent: Bool = false, completion: @escaping (Bool, String?) -> Void) {
            let parameters = [
                "includeCalendar": "false"
            ]

            let module = "kkid/chorelist"
            let jsonArrayName = "chore"
            let coreDataEntityName = "Chore"

            apiSync(silent: silent, parameters: parameters, module: module, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName) { (success, error) in
                completion(success, error)
            }
        }

    // MARK: getWishes
    class func getWishes(silent: Bool = false, completion: @escaping (Bool, String?) -> Void) {
        let module = "kkid/wishlist"
        let jsonArrayName = "wish"
        let coreDataEntityName = "Wish"

        apiSync(silent: silent, parameters: [:], module: module, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName) { (success, error) in
            completion(success, error)
        }
    }

    // MARK: apiSync
    //    Get function to sync data from KKids API to CoreData
        class func apiSync(silent: Bool = false, parameters: [String: Any], module: String, jsonArrayName: String, coreDataEntityName: String, completion: @escaping (Bool, String?) -> Void) {
            let baseURL = self.baseURL
            if !silent {
                ShowAlert.statusLineStatic(id: "get\(coreDataEntityName)", theme: .warning, title: "Syncing", message: "Syncing \(coreDataEntityName) Information....")
            }
            let url = URL(string: "\(baseURL)/\(module)")!

            let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: ["X-Auth":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")"]).responseSwiftyJSON(queue: queue) { dataResponse in

                //            GUARD: API Key Valid (returns 401 when not valid)
                guard let statusCode = dataResponse.response?.statusCode, statusCode != 401 else {
                    Logger.log(.error, "API Key Not Valid")
                    ShowAlert.dismissStatic(id: "get\(coreDataEntityName)")
                    self.logout()
                    return
                }
                if let jsonObject = dataResponse.value, let JSON = jsonObject[jsonArrayName].arrayObject as? [[String: Any]] {
                    DataController.shared.backgroundContext.sync(JSON, inEntityNamed: coreDataEntityName) { _ in
                        completion(true, nil)

                    }

                } else if let error = dataResponse.error {
                    completion(false, error.localizedDescription)
                } else {
                    Logger.log(.error, dataResponse.value as Any)
                }
                try? DataController.shared.backgroundContext.save()
                ShowAlert.dismissStatic(id: "get\(coreDataEntityName)")
                UserDefaults.standard.set(Date(), forKey: "\(coreDataEntityName)LastUpdated")
            }

        }
}
