//
//  TMDb_TV_Rating.swift
//  KKid
//
//  Created by Justin Kumpe on 10/29/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation

struct TMDb_TV_Rating_Response: Codable {
    let results: [TMDb_TV_Rating]?
}

struct TMDb_TV_Rating: Codable {
    let country: String?
    let rating: String?

    private enum CodingKeys : String, CodingKey {
        case country = "iso_3166_1", rating
    }
}
