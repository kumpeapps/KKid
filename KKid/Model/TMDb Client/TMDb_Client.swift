//
//  TMDb_Client.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation
import KumpeHelpers
import ContentRestrictionsKit
import Alamofire
import Alamofire_SwiftyJSON

class TMDb_Client: KumpeAPIClient {

    // MARK: getToken
    class func getToken(completion: @escaping (Bool, String?) -> Void) {
        let url = "\(TMDb_Constants.baseUrl)/authentication/token/new"
        let parameters = [
            "api_key":"\(TMDb_Constants.apiKey)"
        ]
        TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Token.self, parameters: parameters) { (response, error, _) in
            // GUARD: Success
            guard error == nil else {
                completion(false,nil)
                return
            }
            completion(true,response?.requestToken)
        }
    }

    // MARK: getSession
    class func getSession(requestToken: String) {
        let url = "\(TMDb_Constants.baseUrl)/authentication/session/new"
        let parameters = [
            "api_key":"\(TMDb_Constants.apiKey)",
            "request_token":"\(requestToken)"
        ]
        TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Session.self, parameters: parameters) { (response, error, _) in
            // GUARD: Success
            guard error == nil else {
                return
            }
            guard response!.success else {
                return
            }
            // GUARD: selectedUser not nil
            guard let user = LoggedInUser.selectedUser else {
                return
            }
            KumpeAppsClient.updateUser(username: user.username!, email: user.email!, firstName: user.firstName!, lastName: user.lastName!, user: user, emoji: user.emoji!, enableAllowance: user.enableAllowance, enableWishList: user.enableWishList, enableChores: user.enableChores, enableAdmin: user.isAdmin, enableTmdb: user.enableTmdb, tmdbKey: response!.sessionId) { (success, _) in
                if success {
                    KumpeAppsClient.getUsers(silent: true) { (_, _) in
                        ShowAlert.banner(theme: .success, title: "Account Linked", message: "Your TMDb account has been linked sucessfully to KKid user \(user.username!).")
                    }
                }
            }
        }
    }
}
