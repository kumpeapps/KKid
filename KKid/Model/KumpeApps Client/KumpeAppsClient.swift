//
//  KumpeAppsClient.swift
//  KKid
//
//  Created by Justin Kumpe on 10/21/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import CoreData
import KumpeHelpers

class KumpeAppsClient: KumpeAPIClient {

    // MARK: API Creds
    static let appkey = APICredentials.KKid.apikey
    static var baseURL: String {
        #if DEBUG
            return "https://restapi.preprod.kumpeapps.com/v5"
        #else
            return "https://restapi.kumpeapps.com/v5"
        #endif
    }
    static var imageURL: String {
        return "https://filedn.com/l4NBevKntNz45sv2UTxRFDL/images"
    }

    static var appVersion = "KKid"

    // MARK: - Authentication

    // MARK: logout
        class func logout(userInitiated: Bool = false) {
            dispatchOnMain {
                if !userInitiated {
                    ShowAlert.statusLine(theme: .error, title: "Session Expired", message: "Your session has expired. Please login again.", seconds: 10)
                    Logger.log(.authentication, "User Session Expired")
                } else {
                    ShowAlert.statusLine(theme: .success, title: "Logout Successful", message: "Logout Successful", seconds: 10)
                    Logger.log(.authentication, "User Logged Out")
                    apiLogout(UserDefaults.standard.string(forKey: "apiKey") ?? "none")
                }
                UserDefaults.standard.set(false, forKey: "isAuthenticated")
                UserDefaults.standard.removeObject(forKey: "apiKey")
                UserDefaults.standard.removeObject(forKey: "userID")
                NotificationCenter.default.post(name: .isAuthenticated, object: nil)
            }
        }

    // MARK: apiLogout
        class func apiLogout(_ apiKey: String) {
            let parameters = [
                "auth_key": "\(apiKey)"
            ]
            let headers: HTTPHeaders = ["X-Auth":appkey]
            apiPut(silent: true, apiUrl: "\(baseURL)/authkey", parameters: parameters, headers: headers) { _, _, _ in }
        }

    // MARK: verifyIsAuthenticated
        class func verifyIsAuthenticated(_ viewController: UIViewController) {
            if !UserDefaults.standard.bool(forKey: "isAuthenticated") {
                if let navigation = viewController.navigationController {
                    navigation.popToRootViewController(animated: true)
                } else {
                    viewController.dismiss(animated: true, completion: nil)
                }
            }
        }

    // MARK: forgotPassword
        class func forgotPassword(username: String, completion: @escaping (Bool, String) -> Void) {
            let url = "https://www.kumpeapps.com/api/check-access/send-pass"
            let parameters = [
                "_key": "APIResetPasswordLink",
                "login": "\(username)"
            ]

            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default) .responseSwiftyJSON { dataResponse in

                guard let data = dataResponse.value, data["ok"].boolValue else {
                    completion(false, "An Error Occurred. Your username/email may not exist.")
                    return
                }

                completion(true, data["msg"].stringValue)
            }
        }
}
