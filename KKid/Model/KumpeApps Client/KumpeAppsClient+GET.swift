//
//  KumpeAppsClient+GET.swift
//  KKid
//
//  Created by Justin Kumpe on 10/21/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import KumpeHelpers

extension KumpeAppsClient {
    // MARK: - Get Methods (non-sync get methods)

    // MARK: authenticate
    class func authenticate(username: String, password: String, otp: String? = nil, completion: @escaping (_ response: KKid_Auth_Response?, _ error: String?, _ statusResponse: HTTP_Status_Response) -> Void) {
            var parameters = [
                "username": username,
                "password": password,
                "verifyOtp": "true"
            ]
        if otp != nil {
            parameters["otp"] = otp!
        }
            let headers: HTTPHeaders = ["X-Auth":appkey]
            var userAuthResponse: KKid_Auth_Response = KKid_Auth_Response.init(user: nil, apiKey: nil, status: 0, error: nil)

            taskForGet(apiUrl: "\(baseURL)/authentication/authkey", responseType: KumpeApps_Auth_Response.self, parameters: parameters, headers: headers) { response, error, statusResponse in
                guard let response = response else {
                    completion(nil,error, statusResponse)
                    return
                }
                guard response.success ?? false else {
                    let user: KKid_Auth_Response = KKid_Auth_Response.init(user: nil, apiKey: nil, status: 0, error: "Authentication Failed")
                    completion(user,nil, statusResponse)
                    return
                }
                userAuthResponse.apiKey = response.authKey
                userAuthResponse.status = 1
                taskForGet(apiUrl: "\(baseURL)/kkid/user", responseType: KKid_User_Response.self, parameters: ["enableBool":"true"], headers: ["X-Auth":response.authKey ?? ""]) { userResponse, userError, _ in
                    userAuthResponse.user = userResponse?.user
                    completion(userAuthResponse,userError, statusResponse)
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }

    // MARK: getAllowance
        class func getAllowance(silent: Bool = false, selectedUser: User, completion: @escaping (KKid_AllowanceResponse?, String?) -> Void) {
            ShowAlert.statusLineStatic(id: "getAllowance", theme: .warning, title: "Syncing", message: "Syncing Allowance Data....", blockInterface: true)

            let parameters = [
                "transactionDays": "90",
                "kidUserId": "\(selectedUser.userID)"
            ]

            let module = "kkid/allowance"
            let headers = ["X-Auth":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")"]

            taskForGet(apiUrl: "\(baseURL)/\(module)", responseType: KKid_AllowanceResponse.self, parameters: parameters, headers: headers) { response, error, _ in
                completion(response, error)
                ShowAlert.dismissStatic(id: "getAllowance")
            }

        }

    // MARK: getShareLink
    class func getShareLink(silent: Bool = false, selectedUser: User, scope: ShareLinkScope = .wishList, completion: @escaping (KKid_Share_Response?, String?) -> Void) {
            ShowAlert.statusLineStatic(id: "getShareLink", theme: .warning, title: "Syncing", message: "Creating Share Link....", blockInterface: true)

            let parameters = [
                "link": "\(scope.link)",
                "linkUserId": "\(selectedUser.userID)",
                "scope": "\(scope.name)"
            ]

            let module = "kkid/share"
            let headers = ["X-Auth":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")"]

            taskForGet(apiUrl: "\(baseURL)/\(module)", responseType: KKid_Share_Response.self, parameters: parameters, headers: headers, successCode: 201) { response, error, _ in
                completion(response, error)
                ShowAlert.dismissStatic(id: "getShareLink")
            }

        }
}
