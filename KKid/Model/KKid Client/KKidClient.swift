//
//  KKidClient.swift
//  KKid
//
//  Created by Justin Kumpe on 9/8/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import CoreData
import KumpeHelpers

class KKidClient {

// MARK: API Creds
    static let username = APICredentials.KKid.username
    static let apiPassword = APICredentials.KKid.apiPassword
    static let baseURL = "https://api.kumpeapps.com/kkids"
    static let preprodURL = "https://preprod.kumpeapps.com/api/kkids"

    static var appVersion = "KKid"

// MARK: - apiMethod
    class func apiMethod(silent: Bool = false, method: HTTPMethod, module: String, parameters: [String: Any], blockInterface: Bool = false, completion: @escaping (Bool, String?) -> Void) {
        var baseURL = self.baseURL
        #if DEBUG
            baseURL = preprodURL
        #endif
            let url = URL(string: "\(baseURL)/\(module)")!
            let alertId = "post_\(module)_\(Int.random(in: 0..<10))"
            if !silent {
                ShowAlert.statusLineStatic(id: alertId, theme: .warning, title: "Sending Data To \(module)", message: "Sending Data To \(module), Please Wait ....", blockInterface: blockInterface)
            }
            let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseSwiftyJSON(queue: queue) { dataResponse in

//            GUARD: API Key Valid (returns 412 when not valid)
            guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else {
                Logger.log(.error, "API Key Not Valid")
                ShowAlert.dismissStatic(id: alertId)
                completion(false, "API Key Not Valid")
                self.logout()
                return
            }

    //            GUARD: Status code 2xx
            guard statusCode >= 200 && statusCode <= 299 else {
                    Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                    ShowAlert.dismissStatic(id: alertId)
                    var errorMessage = "Unknown Error Occurred"
                    switch statusCode {
                    case 412: errorMessage = "API Key Not Valid"
                    case 409: errorMessage = "The username/email already exists or does not meet the requirements."
                    case 410: errorMessage = "Delete unsuccessful. User/Chore may not exist."
                    case 451: errorMessage = "App has been blocked for legal reasons. Please email helpdesk@kumpeapps.com for more information!"
                    default: errorMessage = "Unknown Error Occurred"
                    }
                    completion(false, errorMessage)
                    return
                }

//            GUARD: isSuccess
            guard case dataResponse.result.isSuccess = true else {
                completion(false, dataResponse.error?.localizedDescription)
                ShowAlert.dismissStatic(id: alertId)
                return
            }

                ShowAlert.dismissStatic(id: alertId)
                completion(true, nil)
            }
        }

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
        let method = "authentication"
        let parameters = [
            "apiUsername": KKidClient.username,
            "apiPassword": KKidClient.apiPassword,
            "apiKey": "\(apiKey)"
        ]
        KKidClient.apiPut(silent: true, module: method, parameters: parameters) { (_, _) in }
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
