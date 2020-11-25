//
//  KKidClient+Sync.swift
//  KKid
//
//  Created by Justin Kumpe on 9/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

import Alamofire
import Alamofire_SwiftyJSON
import Sync
import CoreData
import KumpeHelpers

extension KKidClient {

    // MARK: - API to CoreData Syncs

    // MARK: getUsers
        class func getUsers(silent: Bool = false, completion: @escaping (Bool, String?) -> Void) {
            let parameters = [
                "apiUsername": KKidClient.username,
                "apiPassword": KKidClient.apiPassword,
                "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
                "boolAsInt": "true",
                "outputCase": "snake"
            ]

            let module = "userlist"
            let jsonArrayName = "user"
            let coreDataEntityName = "User"

            apiSync(silent: silent, parameters: parameters, module: module, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName) { (success, error) in
                completion(success, error)
                NotificationCenter.default.post(name: .isAuthenticated, object: nil)
            }
        }

    // MARK: getChores
        class func getChores(silent: Bool = false, completion: @escaping (Bool, String?) -> Void) {
            let parameters = [
                "apiUsername": KKidClient.username,
                "apiPassword": KKidClient.apiPassword,
                "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
                "boolAsInt": "true",
                "includeCalendar": "true",
                "outputCase": "snake"
            ]

            let module = "chorelist"
            let jsonArrayName = "chore"
            let coreDataEntityName = "Chore"

            apiSync(silent: silent, parameters: parameters, module: module, jsonArrayName: jsonArrayName, coreDataEntityName: coreDataEntityName) { (success, error) in
                completion(success, error)
            }

        }

    // MARK: apiSync
    //    Get function to sync data from KKids API to CoreData
        class func apiSync(silent: Bool = false, parameters: [String: Any], module: String, jsonArrayName: String, coreDataEntityName: String, completion: @escaping (Bool, String?) -> Void) {
            var baseURL = self.baseURL
            #if DEBUG
                baseURL = preprodURL
            #endif
            if !silent {
                ShowAlert.statusLineStatic(id: "get\(coreDataEntityName)", theme: .warning, title: "Syncing", message: "Syncing \(coreDataEntityName) Information....")
            }
            let url = URL(string: "\(baseURL)/\(module)")!

            let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON(queue: queue) { dataResponse in

                //            GUARD: API Key Valid (returns 412 when not valid)
                guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else {
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
