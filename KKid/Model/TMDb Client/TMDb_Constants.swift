//
//  TMDb_Constants.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation
import Keys

public struct TMDb_Constants {
    static let apiKey = KKidKeys().tmdb_apiKey
    static let baseUrl = "https://api.themoviedb.org/3"
    static let searchUrl = "\(baseUrl)/search"
    static let favoriteMoviesUrl = "\(baseUrl)/account/1/favorite/movies"
    static let watchlistMoviesUrl = "\(baseUrl)/account/1/watchlist/movies"
    static let postFavorite = "\(baseUrl)/account/1/favorite"
    static let postWatchList = "\(baseUrl)/account/1/watchlist"
    static let searchMoviesUrl = "\(searchUrl)/movie"
    static let imageBaseUrl = "https://image.tmdb.org/t/p"
    static let trailerBaseURL = "https://www.youtube.com/watch?v="

    enum Language: String {
        case englishUS = "en-US"
    }

    enum PosterUrl: String {
        case w92
        case w154
        case w185
        case w342
        case w500
        case w780
        case original

        var baseUrl: String {
            switch self {
            case .w92:
                return "\(TMDb_Constants.imageBaseUrl)/w92"
            case .w154:
                return "\(TMDb_Constants.imageBaseUrl)/w154"
            case .w185:
                return "\(TMDb_Constants.imageBaseUrl)/w185"
            case .w342:
                return "\(TMDb_Constants.imageBaseUrl)/w3342"
            case .w500:
                return "\(TMDb_Constants.imageBaseUrl)/w500"
            case .w780:
                return "\(TMDb_Constants.imageBaseUrl)/w780"
            case .original:
                return "\(TMDb_Constants.imageBaseUrl)/original"
            }
        }
    }

    enum BackDropUrl: String {
        case w300
        case w780
        case w1280
        case original

        var baseUrl: String {
            switch self {
            case .w300:
                return "\(TMDb_Constants.imageBaseUrl)/w300"
            case .w780:
                return "\(TMDb_Constants.imageBaseUrl)/w780"
            case .w1280:
                return "\(TMDb_Constants.imageBaseUrl)/w1280"
            case .original:
                return "\(TMDb_Constants.imageBaseUrl)/original"
            }
        }
    }
}
