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
    let total_results: Int
    let total_pages: Int
}

typealias TMDb_TV = TMDb_Movie
