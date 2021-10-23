//
//  KKidClient+GET.swift
//  KKid
//
//  Created by Justin Kumpe on 9/18/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
/*
import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import KumpeHelpers

extension KKidClient {

    // MARK: - Get Methods (non-sync get methods)

    // MARK: authenticate
        class func authenticate(username: String, password: String, completion: @escaping (KKid_Auth_Response?, String?) -> Void) {
            let parameters = [
                "apiUsername": KKidClient.username,
                "apiPassword": KKidClient.apiPassword,
                "username": username,
                "password": password
            ]
            let module = "authentication"

            taskForGet(module: module, responseType: KKid_Auth_Response.self, parameters: parameters) { (response, error) in
                completion(response, error)
            }
        }

    // MARK: getAllowance
        class func getAllowance(silent: Bool = false, selectedUser: User, completion: @escaping (KKid_AllowanceResponse?, String?) -> Void) {
            ShowAlert.statusLineStatic(id: "getAllowance", theme: .warning, title: "Syncing", message: "Syncing Allowance Data....", blockInterface: true)

            let parameters = [
                "apiUsername": KKidClient.username,
                "apiPassword": KKidClient.apiPassword,
                "apiKey": "\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
                "transactionDays": "90",
                "kidUserId": "\(selectedUser.userID)"
            ]

            let module = "allowance"

            taskForGet(module: module, responseType: KKid_AllowanceResponse.self, parameters: parameters) { (response, error) in
                completion(response, error)
                ShowAlert.dismissStatic(id: "getAllowance")
            }

        }

    // MARK: Task For Get
    class func taskForGet<ResponseType: Decodable>(module: String, responseType: ResponseType.Type, parameters: [String: String], completion: @escaping (ResponseType?, String?) -> Void) {
        var baseURL = self.baseURL
        #if DEBUG
            baseURL = preprodURL
        #endif

        let url = URL(string: "\(baseURL)/\(module)")!
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default) .responseSwiftyJSON { dataResponse in

    //            GUARD: isSuccess
                guard case dataResponse.result.isSuccess = true else {
                    completion(nil, dataResponse.error?.localizedDescription)
                    return
                }

    //            GUARD: API Key Valid (returns 412 when not valid)
                guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else {
                    self.logout()
                    return
                }

    //            GUARD: Status code 2xx
                    guard statusCode >= 200 && statusCode <= 299 else {
                        Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                        return
                    }

        //            GUARD: Status Code 200
                    guard statusCode == 200 else {
                        Logger.log(.error, "No Data Found")
                            return
                    }

    //            GUARD: Response
                guard let data = dataResponse.data else {
                    completion(nil, dataResponse.error?.localizedDescription)
                    Logger.log(.error, "No Data Found.")
                    return
                }

                        do {
                            let decoder = JSONDecoder()
                            let response = try decoder.decode(responseType.self, from: data)
                            completion(response, nil)
                        } catch let error {
                            Logger.log(.error, "Task For Get: \(error.localizedDescription)")
                            completion(nil, error.localizedDescription)
                        }

                    }
        }

}
*/
