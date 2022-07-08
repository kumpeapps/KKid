//
//  KKid_Share.swift
//  KKid
//
//  Created by Justin Kumpe on 7/6/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import Foundation

struct KKid_Share_Response: Codable {

    let success: Bool?
    let authLink: String?

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case authLink = "auth_link"
    }

}
