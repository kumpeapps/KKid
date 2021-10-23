//
//  KumpeApps_Auth_Response.swift
//  KKid
//
//  Created by Justin Kumpe on 10/21/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation

struct KumpeApps_Auth_Response: Codable {
    var authKey: String?
    var success: Bool?

    enum CodingKeys: String, CodingKey {
        case authKey = "auth_key"
        case success
    }
}
