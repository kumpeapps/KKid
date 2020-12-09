//
//  TMDb_Movie.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation

struct TMDb_Movie_Response: Codable {
    let page: Int
    var results: [TMDb_Movie]
    let totalResults: Int
    let totalPages: Int
    
    private enum CodingKeys : String, CodingKey {
        case page, results, totalResults = "total_results", totalPages = "total_pages"
    }
}

struct TMDb_Movie: Codable {
    let posterPath: String?
    let adult: Bool?
    let overview: String?
    let releaseDate: String?
    let id: Int?
    let originalTitle: String?
    let originalLanguage: String?
    let title: String?
    let backdropPath: String?
    let popularity: Float?
    let voteCount: Int?
    let voteAverage: Float?
    var movieRating: String?
    var trailerKey: String?

    private enum CodingKeys : String, CodingKey {
        case posterPath = "poster_path", adult, overview, releaseDate = "release_date", id, originalTitle = "original_title", originalLanguage = "original_language", title, backdropPath = "backdrop_path", popularity, voteCount = "vote_count", voteAverage = "vote_average", movieRating = "certification", trailerKey
    }
}
