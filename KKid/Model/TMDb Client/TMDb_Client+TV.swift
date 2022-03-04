//
//  TMDb_Client+TV.swift
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

    // MARK: searchTV
        class func searchTV(query: String, page: Int, completion: @escaping (Bool, TMDb_TV_Response?) -> Void) {
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

            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.searchTVUrl, responseType: TMDb_TV_Response.self, parameters: parameters) { (response, _) in
                let taskGroup = DispatchGroup()
                var tvResponse = response
                var removeShows: [Int] = []
                var shows: [TMDb_TV] = tvResponse?.results ?? []
                for index in shows.indices {
                    taskGroup.enter()
                    self.getTVRating(show: shows[index]) { (success, rating) in
                        if success {
                            shows[index].movieRating = rating
                        } else {
                            shows[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: shows[index].movieRating!) {
                            removeShows.append(index)
                        }
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    tvResponse?.results = shows
                    completion(true,tvResponse)
                }
            }
        }

    // MARK: getTVTrailer
        class func getTVTrailer(movie: TMDb_TV, completion: @escaping (Bool, String?) -> Void) {
            let url = "\(TMDb_Constants.baseUrl)/tv/\(movie.id!)/videos"
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

        // MARK: getTVRating
        class func getTVRating(show: TMDb_TV, completion: @escaping (Bool, String?) -> Void) {
            let url = "\(TMDb_Constants.baseUrl)/tv/\(show.id!)/content_ratings"
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "language":"en-US"
            ]
            TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_TV_Rating_Response.self, parameters: parameters) { (response, error) in
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
                    rating = result.rating ?? "unknown"
                }

                completion(true,rating.lowercased())
            }
        }

        // MARK: getFavoriteShows
        class func getFavoriteShows(page: Int = 1, sessionId: String, completion: @escaping (Bool,TMDb_TV_Response?) -> Void) {
            guard sessionId != "" else {
                completion(false,nil)
                return
            }
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "session_id":"\(sessionId)",
                "page":"\(page)"
            ]
            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.favoriteShowsUrl, responseType: TMDb_TV_Response.self, parameters: parameters) { (response, error) in

                if let error = error {
                    ShowAlert.banner(title: error, message: "Your TMDb account needs to be re-linked in your User Profile.")
                }

                let taskGroup = DispatchGroup()
                guard var tvResponse = response else {
                    completion(false,nil)
                    return
                }
                var removeShows: [Int] = []
                var shows: [TMDb_TV] = tvResponse.results
                for index in shows.indices {
                    taskGroup.enter()
                    self.getTVRating(show: shows[index]) { (success, rating) in
                        if success {
                            shows[index].movieRating = rating
                        } else {
                            shows[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: shows[index].movieRating!) {
                            removeShows.append(index)
                        }
                        shows[index].favorite = true
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    tvResponse.results = shows
                    completion(true,tvResponse)
                }
            }
        }

        // MARK: getTVWatchlist
        class func getTVWatchlist(page: Int = 1, sessionId: String, completion: @escaping (Bool,TMDb_TV_Response?) -> Void) {
            guard sessionId != "" else {
                completion(false,nil)
                return
            }
            let parameters = [
                "api_key":"\(TMDb_Constants.apiKey)",
                "session_id":"\(sessionId)",
                "page":"\(page)"
            ]

            TMDb_Client.taskForGet(apiUrl: TMDb_Constants.watchlistShowsUrl, responseType: TMDb_TV_Response.self, parameters: parameters) { (response, error) in

                if let error = error {
                    ShowAlert.banner(title: error, message: "Your TMDb account needs to be re-linked in your User Profile.")
                }

                let taskGroup = DispatchGroup()
                var showResponse = response
                var removeMovies: [Int] = []
                var shows: [TMDb_TV] = showResponse?.results ?? []
                for index in shows.indices {
                    taskGroup.enter()
                    self.getTVRating(show: shows[index]) { (success, rating) in
                        if success {
                            shows[index].movieRating = rating
                        } else {
                            shows[index].movieRating = "nr"
                        }
                        if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: shows[index].movieRating!) {
                            removeMovies.append(index)
                        }
                        shows[index].favorite = true
                        taskGroup.leave()
                    }
                }
                taskGroup.notify(queue: .main) {
                    showResponse?.results = shows
                    completion(true,showResponse)
                }
            }
        }

    }
