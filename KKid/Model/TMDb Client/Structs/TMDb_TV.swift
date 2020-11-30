//
//  TMDb_TV.swift
//  KKid
//
//  Created by Justin Kumpe on 11/29/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

struct TMDb_TV_Response: Codable {
    let page: Int
    let results: [TMDb_TV]
    let totalResults: Int
    let totalPages: Int
    
    private enum CodingKeys : String, CodingKey {
        case page, results, totalResults = "total_results", totalPages = "total_pages"
    }
}

typealias TMDb_TV = TMDb_Movie
