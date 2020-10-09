//
//  LoggedInUser.swift
//  KKid
//
//  Created by Justin Kumpe on 9/12/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData


class LoggedInUser {
    
    //    MARK: Static Params
    static var user:User? {
        didSet{
            loggedIn()
        }
    }
    
    static var selectedUser:User?
    
    class func loggedIn(){
        UserDefaults.standard.set(user?.userID ?? 0, forKey: "userID")
        UserDefaults.standard.set(user?.isAdmin ?? false, forKey: "isAdmin")
        UserDefaults.standard.set(user?.masterID ?? 0, forKey: "masterID")
        setSelectedToLoggedIn()
    }
    
    class func setSelectedToLoggedIn(){
        selectedUser = user
    }
    
    class func setLoggedInUser(){
        let loggedInUserID = UserDefaults.standard.integer(forKey: "loggedInUserID")
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "userID = %@", NSNumber(value: loggedInUserID))
        fetchRequest.predicate = predicate
        do {
            let users = try? DataController.shared.viewContext.fetch(fetchRequest)
            assert(users!.count < 2)
            if let user = users?.first{
                LoggedInUser.user = user
            }
        }
        
    }
}
