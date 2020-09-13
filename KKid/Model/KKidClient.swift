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
import Base32
import Sync
import CoreData

class KKidClient {
       
//    MARK: API Creds
    static let username = "Apps_KKid"
    #error("Must set apiPassword and remove this line before compiling")
    static let apiPassword = ""
    static let baseURL = "https://api.kumpeapps.com/kkids"
    
    
    class func authenticate(username: String, password: String, completion: @escaping (KKid_Auth_Response?, String?) -> Void){
        let url = URL(string: "\(KKidClient.baseURL)/authentication")!
        let parameters = [
            "apiUsername":KKidClient.username,
            "apiPassword":KKidClient.apiPassword,
            "username":username,
            "password":password
        ]
        
        
        taskForGet(url: url, responseType: KKid_Auth_Response.self, parameters: parameters){
            (response, error) in
            completion(response, error)
        }
    }
    
    class func getUsers(completion: @escaping (Bool, String?) -> Void){
        
        ShowAlert.statusLineStatic(id: "getUsers", theme: .warning,title: "Syncing", message: "Syncing User Information....")
        let url = URL(string: "\(KKidClient.baseURL)/userlist")!
        let parameters = [
            "apiUsername":KKidClient.username,
            "apiPassword":KKidClient.apiPassword,
            "apiKey":"\(UserDefaults.standard.value(forKey: "apiKey") ?? "null")",
            "boolAsInt":"true",
            "outputCase":"snake"
        ]
        let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON(queue: queue) { dataResponse in
            
            //            GUARD: API Key Valid (returns 412 when not valid)
            guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else{
                Logger.log(.error, "API Key Not Valid")
                ShowAlert.dismissStatic(id: "getUsers")
                self.logout()
                return
            }
            
            if let jsonObject = dataResponse.value, let usersJSON = jsonObject["user"].arrayObject as? [[String: Any]] {
                
                DataController.shared.backgroundContext.sync(usersJSON, inEntityNamed: "User") { error in
                    completion(true,nil)
                    
                }
                
            } else if let error = dataResponse.error {
                completion(false,error.localizedDescription)
            } else {
                Logger.log(.error, dataResponse.value as Any)
            }
            try? DataController.shared.backgroundContext.save()
            ShowAlert.dismissStatic(id: "getUsers")
        }
        
    }
    
    
//    MARK: Task For Get
    class func taskForGet<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, parameters: [String:String], completion: @escaping (ResponseType?, String?) -> Void){
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default) .responseSwiftyJSON { dataResponse in
                    
//            GUARD: isSuccess
            guard case dataResponse.result.isSuccess = true else {
                completion(nil,dataResponse.error?.localizedDescription)
                return
            }
            
//            GUARD: API Key Valid (returns 412 when not valid)
            guard let statusCode = dataResponse.response?.statusCode, statusCode != 412 else{
                self.logout()
                return
            }
            
//            GUARD: Status code 2xx
                guard statusCode >= 200 && statusCode <= 299 else{
                    Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                    return
                }
                        
    //            GUARD: Status Code 200
                guard statusCode == 200 else{
                    Logger.log(.error, "No Data Found")
                        return
                }
                    
//            GUARD: Response
            guard let data = dataResponse.data else{
                completion(nil,dataResponse.error?.localizedDescription)
                Logger.log(.error, "No Data Found.")
                return
            }
                    
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(responseType.self, from: data)
                        completion(response,nil)
                    } catch let error {
                        Logger.log(.error, "Task For Get: \(error.localizedDescription)")
                        completion(nil,error.localizedDescription)
                    }
                    
                    
                }
    }
    
//    MARK: logout
    class func logout(userInitiated: Bool = false){
        dispatchOnMain {
            if !userInitiated{
                ShowAlert.statusLine(theme: .error, title: "Session Expired", message: "Your session has expired. Please login again.", seconds: 10)
                Logger.log(.authentication, "User Session Expired")
            }else{
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
    
    class func apiLogout(_ apiKey: String){
        let url = URL(string: "\(KKidClient.baseURL)/authentication")!
        let parameters = [
            "apiUsername":KKidClient.username,
            "apiPassword":KKidClient.apiPassword,
            "apiKey":"\(apiKey)"
        ]
        let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON(queue: queue) { dataResponse in
            
        }
    }
    
    class func verifyIsAuthenticated(_ viewController: UIViewController){
        if !UserDefaults.standard.bool(forKey: "isAuthenticated"){
            if let navigation = viewController.navigationController{
                navigation.popToRootViewController(animated: true)
            }else{
                viewController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
