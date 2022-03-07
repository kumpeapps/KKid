//
//  KKid_Auth_Response.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_Auth_Response: Codable {
    var user: KKid_User?
    var apiKey: String?
    var status: Int
    var error: String?
}
