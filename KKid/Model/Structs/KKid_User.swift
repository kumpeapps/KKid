//
//  KKid_User.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_User: Codable {

    let userID: Int?
    var masterID: Int?
    var homeID: Int?
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var isActive: Bool?
    var isAdmin: Bool?
    var enableAllowance: Bool?
    var isBanned: Bool?
    var isChild: Bool?
    var enableChores: Bool?
    var isDisabled: Bool?
    var isLocked: Bool?
    var isMaster: Bool?
    var enableBehaviorChart: Bool?
    var weeklyAllowance: Int?
    var emoji: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case masterID = "master_id"
        case homeID = "home_id"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case isActive = "is_active"
        case isAdmin = "is_admin"
        case enableAllowance = "enable_allowance"
        case isBanned = "is_banned"
        case isChild = "is_child"
        case enableChores = "enable_chores"
        case isDisabled = "is_disabled"
        case isLocked = "is_locked"
        case isMaster = "is_master"
        case enableBehaviorChart = "enable_behavior_chart"
        case weeklyAllowance = "weekly_allowance"
        case emoji
    }

}

struct KKid_User_Response: Codable {
    var success: Bool?
    var user: KKid_User?
}
