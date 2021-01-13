//
//  TMDb_Token.swift
//  KKid
//
//  Created by Justin Kumpe on 1/6/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation

struct TMDb_Token: Codable {
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    private enum CodingKeys : String, CodingKey {
        case success, expiresAt = "expires_at", requestToken = "request_token"
    }
}
