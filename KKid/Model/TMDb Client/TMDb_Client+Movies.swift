//
//  TMDb_Client+Movies.swift
//  KKid
//
//  Created by Justin Kumpe on 10/28/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation
import KumpeHelpers
import ContentRestrictionsKit
import Alamofire
import Alamofire_SwiftyJSON

extension TMDb_Client {

    // MARK: searchMovies
        class func searchMovies(query: String, page: Int, completion: @escaping (Bool, TMDb_Movie_Response?) -> Void) {
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "query":"\(query)",
                "include_adult":"false",
                "page":"\(page)"
            ]

            guard query.lowercased() != "porn" && query.lowercased() != "porno" && query.lowercased() != "pornography" else {
                completion(false,nil)
                return
            }

            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.searchMoviesUrl, responseType: TMDb_Movie_Response.self, parameters: parameters) { (response, _) in
                let taskGroup = DispatchGroup()
                var movieResponse = response
                var removeMovies: [Int] = []
                var movies: [TMDb_Movie] = movieResponse?.results ?? []
                for index in movies.indices {
                    taskGroup.enter()
                    self.getMovieRating(movie: movies[index]) { (success, rating) in
                        if success {
                            movies[index].movieRating = rating
                        } else {
                            movies[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: movies[index].movieRating!) {
                            removeMovies.append(index)
                        }
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    movieResponse?.results = movies
                    completion(true,movieResponse)
                }
            }
        }

    // MARK: getMovieTrailer
        class func getMovieTrailer(movie: TMDb_Movie, completion: @escaping (Bool, String?) -> Void) {
            let url = "\(TMDb_Constants.baseUrl)/movie/\(movie.id!)/videos"
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "language":"en-US"
            ]

            TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Video_Response.self, parameters: parameters) { (response, error) in

                // GUARD: Success
                guard error == nil else {
                    completion(false,error)
                    return
                }

                // GUARD: results exist
                guard let results = response?.results else {
                    completion(false,"")
                    return
                }
                var trailerKey = ""
                for result in results where result.type == "Trailer" {
                        trailerKey = result.key!
                }
                guard trailerKey != "" else {
                    completion(false,"")
                    return
                }
                completion(true,trailerKey)
            }
        }

        // MARK: getMovieRating
        class func getMovieRating(movie: TMDb_Movie, completion: @escaping (Bool, String?) -> Void) {
            let url = "\(TMDb_Constants.baseUrl)/movie/\(movie.id!)/release_dates"
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "language":"en-US"
            ]
            TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Movie_ReleaseDates_Response.self, parameters: parameters) { (response, error) in
                // GUARD: Success
                guard error == nil else {
                    completion(false,error)
                    return
                }

                // GUARD: results exist
                guard let results = response?.results else {
                    completion(true,"unknown")
                    return
                }

                var rating = "unknown"

                for result in results where result.country == "US" {
                    for release in result.releaseDates where release.movieRating != "" {
                        rating = release.movieRating!.replacingOccurrences(of: "-", with: "")
                    }
                }

                completion(true,rating.lowercased())
            }
        }

        // MARK: getFavoriteMovies
        class func getFavoriteMovies(page: Int = 1, sessionId: String, completion: @escaping (Bool,TMDb_Movie_Response?) -> Void) {
            guard sessionId != "" else {
                completion(false,nil)
                return
            }
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "session_id":"\(sessionId)",
                "page":"\(page)"
            ]
            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.favoriteMoviesUrl, responseType: TMDb_Movie_Response.self, parameters: parameters) { (response, _) in
                let taskGroup = DispatchGroup()
                guard var movieResponse = response else {
                    completion(false,nil)
                    return
                }
                var removeMovies: [Int] = []
                var movies: [TMDb_Movie] = movieResponse.results
                for index in movies.indices {
                    taskGroup.enter()
                    self.getMovieRating(movie: movies[index]) { (success, rating) in
                        if success {
                            movies[index].movieRating = rating
                        } else {
                            movies[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: movies[index].movieRating!) {
                            removeMovies.append(index)
                        }
                        movies[index].favorite = true
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    movieResponse.results = movies
                    completion(true,movieResponse)
                }
            }
        }

        // MARK: getMovieWatchlist
        class func getMovieWatchlist(page: Int = 1, sessionId: String, completion: @escaping (Bool,TMDb_Movie_Response?) -> Void) {
            guard sessionId != "" else {
                completion(false,nil)
                return
            }
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "session_id":"\(sessionId)",
                "page":"\(page)"
            ]

            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.watchlistMoviesUrl, responseType: TMDb_Movie_Response.self, parameters: parameters) { (response, _) in
                let taskGroup = DispatchGroup()
                var movieResponse = response
                var removeMovies: [Int] = []
                var movies: [TMDb_Movie] = movieResponse?.results ?? []
                for index in movies.indices {
                    taskGroup.enter()
                    self.getMovieRating(movie: movies[index]) { (success, rating) in
                        if success {
                            movies[index].movieRating = rating
                        } else {
                            movies[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: movies[index].movieRating!) {
                            removeMovies.append(index)
                        }
                        movies[index].favorite = true
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    movieResponse?.results = movies
                    completion(true,movieResponse)
                }
            }
        }

        // MARK: postFavorite
        class func postFavorite(sessionId: String, mediaType: String, mediaId: Int, favorite: Bool, completion: @escaping (Bool) -> Void) {
            let url = "\(TMDb_Constants.postFavorite)?api_key=\(TMDb_Constants.apiKey)&session_id=\(sessionId)"
            let parameters = [
                "media_type":"\(mediaType)",
                "media_id":"\(mediaId)",
                "favorite":favorite
            ] as [String : Any]
            TMDb_Client.apiPost(apiUrl: url, parameters: parameters, postToBody: true) { (success, _) in
                completion(success)
            }
        }

        // MARK: postWatchlist
        class func postWatchlist(sessionId: String, mediaType: String, mediaId: Int, watchlist: Bool, completion: @escaping (Bool) -> Void) {
            let url = "\(TMDb_Constants.postWatchList)?api_key=\(TMDb_Constants.apiKey)&session_id=\(sessionId)"
            let parameters = [
                "media_type":"\(mediaType)",
                "media_id":"\(mediaId)",
                "watchlist":watchlist
            ] as [String : Any]
            TMDb_Client.apiPost(apiUrl: url, parameters: parameters, postToBody: true) { (success, _) in
                completion(success)
            }
        }

    }
