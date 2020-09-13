//
//  LoggedInUser.swift
//  KKid
//
//  Created by Justin Kumpe on 9/12/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class LoggedInUser {
    
    //    MARK: Static Params
    static var user:KKid_User? {
        didSet{
            loggedIn()
        }
    }
    
    class func loggedIn(){
        UserDefaults.standard.set(user!.userID, forKey: "userID")
        UserDefaults.standard.set(user!.isAdmin, forKey: "isAdmin")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user){
            UserDefaults.standard.set(encoded, forKey: "loggedInUser")
        }
    }
}
