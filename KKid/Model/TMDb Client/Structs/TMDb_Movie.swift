//
//  TMDb_Movie.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation

struct TMDb_Movie_Response: Codable {
    let page: Int
    let results: [TMDb_Movie]
    let total_results: Int
    let total_pages: Int
}

struct TMDb_Movie: Codable {
    let poster_path: String?
    let adult: Bool?
    let overview: String?
    let release_date: String?
    let id: Int?
    let original_title: String?
    let original_language: String?
    let title: String?
    let backdrop_path: String?
    let popularity: Float?
    let vote_count: Int?
    let vote_average: Float?
}
