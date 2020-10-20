//
//  APIClient.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON
import UIKit

open class KumpeAPIClient{
    
//    MARK: apiLogout
//    Initiates logout for invalid API Key
    open class func apiLogout(){
        NotificationCenter.default.post(name: .invalidAPIKey, object: nil)
    }
    
//    MARK: statusCodeDescription
    open class func statusCodeDescription(_ statusCode: Int) -> String{
        var errorMessage = "Unknown Error Occurred"
        switch statusCode{
        case 412: errorMessage = "API Key Not Valid"
        case 409: errorMessage = "The username/email already exists or does not meet the requirements."
        case 410: errorMessage = "Delete unsuccessful. User/Chore may not exist."
        case 451: errorMessage = "App has been blocked for legal reasons. Please email support for more information!"
        default: errorMessage = "Unknown Error Occurred"
        }
        return errorMessage
    }
    
    //    MARK: - apiMethod
    open class func apiMethod(silent: Bool = false, apiUrl: String, httpMethod: HTTPMethod, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 412, completion: @escaping (Bool, String?) -> Void){
                let url = URL(string: apiUrl)!
                let alertId = "api_\(Int.random(in: 0..<10))"
                if !silent{
                    ShowAlert.statusLineStatic(id: alertId, theme: .warning, title: "Sending Data", message: "Sending Data, Please Wait ....", blockInterface: blockInterface)
                }
                let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
            Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseSwiftyJSON(queue: queue) { dataResponse in

    //            GUARD: API Key Valid
                guard let statusCode = dataResponse.response?.statusCode, statusCode != invalidApiKeyStatusCode else{
                    Logger.log(.error, "API Key Not Valid")
                    ShowAlert.dismissStatic(id: alertId)
                    completion(false,"API Key Not Valid")
                    apiLogout()
                    return
                }
                
                    
        //            GUARD: Status code 2xx
                guard statusCode >= 200 && statusCode <= 299 else{
                        Logger.log(.error, "Your request returned a status code other than 2xx! (\(String(describing: dataResponse.response?.statusCode)))")
                        ShowAlert.dismissStatic(id: alertId)
                        let errorMessage = statusCodeDescription(statusCode)
                        completion(false,errorMessage)
                        return
                    }
                
    //            GUARD: isSuccess
                guard case dataResponse.result.isSuccess = true else {
                    completion(false,dataResponse.error?.localizedDescription)
                    ShowAlert.dismissStatic(id: alertId)
                    return
                }
                
                
                    ShowAlert.dismissStatic(id: alertId)
                    completion(true,nil)
                }
            }
}
