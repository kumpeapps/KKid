//
//  KumpeAPIClient+Sync.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/11/20.
//

import Foundation

import Alamofire
import Alamofire_SwiftyJSON
import Sync
import CoreData

extension KumpeAPIClient{
    
    //    MARK: apiSync
    //    Get function to sync data from API to CoreData
    open class func apiSync(silent: Bool = false, apiUrl: String, parameters: [String:Any], jsonArrayName: String, coreDataEntityName: String, invalidApiKeyStatusCode: Int = 412, completion: @escaping (Bool, String?) -> Void){
            
            if !silent{
                ShowAlert.statusLineStatic(id: "sync_\(coreDataEntityName)", theme: .warning, title: "Syncing", message: "Syncing \(coreDataEntityName) Information....")
            }
            let url = URL(string: apiUrl)!
            
            let queue = DispatchQueue(label: "com.kumpeapps.api", qos: .background, attributes: .concurrent)
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON(queue: queue) { dataResponse in
                
                //            GUARD: API Key Valid (returns 412 when not valid)
                guard let statusCode = dataResponse.response?.statusCode, statusCode != invalidApiKeyStatusCode else{
                    Logger.log(.error, "API Key Not Valid")
                    ShowAlert.dismissStatic(id: "sync_\(coreDataEntityName)")
                    apiLogout()
                    return
                }
                if let jsonObject = dataResponse.value, let JSON = jsonObject[jsonArrayName].arrayObject as? [[String: Any]] {
                    
                    DataController.shared.backgroundContext.sync(JSON, inEntityNamed: coreDataEntityName) { error in
                        completion(true,nil)
                        Logger.log(.action, "Sync \(coreDataEntityName) Complete")
                    }
                    
                } else if let error = dataResponse.error {
                    completion(false,error.localizedDescription)
                } else {
                    Logger.log(.error, dataResponse.value as Any)
                }
                try? DataController.shared.backgroundContext.save()
                ShowAlert.dismissStatic(id: "sync_\(coreDataEntityName)")
                UserDefaults.standard.set(Date(), forKey: "\(coreDataEntityName)LastUpdated")
                
            }
            
        }
    
}
