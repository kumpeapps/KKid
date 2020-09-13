//
//  User.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct User: Codable{
    
    let userID: Int
    var masterID: Int
    var homeID: Int
    var username: String
    var firstName: String
    var lastName: String
    var email: String
    var isAdctive: Bool
    var isAdmin: Bool
    var enableAllowance: Bool
    var isBanned: Bool
    var isChild: Bool
    var enableChores: Bool
    var isDisabled: Bool
    var isLocked: Bool
    var isMaster: Bool
    var enableBehaviorChart: Bool
    var weeklyAllowance: Int
    
}
