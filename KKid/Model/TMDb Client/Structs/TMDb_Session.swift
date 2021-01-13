//
//  TMDb_Session.swift
//  KKid
//
//  Created by Justin Kumpe on 1/6/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation

struct TMDb_Session: Codable {
    let success: Bool
    let sessionId: String
    
    private enum CodingKeys : String, CodingKey {
        case success, sessionId = "session_id"
    }
}
