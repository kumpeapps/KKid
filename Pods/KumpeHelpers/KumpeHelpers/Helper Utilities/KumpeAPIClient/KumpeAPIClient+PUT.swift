//
//  KumpeAPIClient+PUT.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_SwiftyJSON

extension KumpeAPIClient{
    
//    MARK: apiPut
    open class func apiPut(silent: Bool = false, apiUrl: String, parameters: [String:Any], blockInterface: Bool = false, invalidApiKeyStatusCode: Int = 412, completion: @escaping (Bool, String?) -> Void){
        apiMethod(silent: silent, apiUrl: apiUrl, httpMethod: .put, parameters: parameters, blockInterface: blockInterface, invalidApiKeyStatusCode: invalidApiKeyStatusCode) { (success, error) in
            completion(success,error)
        }
    }
    
}
