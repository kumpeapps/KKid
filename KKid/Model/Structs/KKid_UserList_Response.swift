//
//  KKid_UserList_Response.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_UserList_Response: Codable{
    var status: Int
    var user: [KKid_User]
}

