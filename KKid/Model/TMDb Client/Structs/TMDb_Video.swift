//
//  TMDb_Video.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/28/20.
//

import Foundation

struct TMDb_Video: Codable {
    let id: String?
    let key: String?
    let name: String?
    let size: Int?
    let type: String?
}

struct TMDb_Video_Response: Codable {
    let id: Int
    let results: [TMDb_Video]?
}
