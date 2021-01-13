//
//  TMDb_Client.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation
import KumpeHelpers
import ContentRestrictionsKit

class TMDb_Client: KumpeAPIClient {

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

    // MARK: getToken
    class func getToken(completion: @escaping (Bool, String?) -> Void) {
        let url = "\(TMDb_Constants.baseUrl)/authentication/token/new"
        let parameters = [
            "api_key":"\(TMDb_Constants.apiKey)"
        ]
        TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Token.self, parameters: parameters) { (response, error) in
            // GUARD: Success
            guard error == nil else {
                completion(false,nil)
                return
            }
            completion(true,response?.requestToken)
        }
    }

    // MARK: getSession
    class func getSession(requestToken: String) {
        let url = "\(TMDb_Constants.baseUrl)/authentication/session/new"
        let parameters = [
            "api_key":"\(TMDb_Constants.apiKey)",
            "request_token":"\(requestToken)"
        ]
        TMDb_Client.taskForGet(apiUrl: url, responseType: TMDb_Session.self, parameters: parameters) { (response, error) in
            // GUARD: Success
            guard error == nil else {
                return
            }
            guard response!.success else {
                return
            }
            // GUARD: selectedUser not nil
            guard let user = LoggedInUser.selectedUser else {
                return
            }
            KKidClient.updateUser(username: user.username!, email: user.email!, firstName: user.firstName!, lastName: user.lastName!, user: user, emoji: user.emoji!, enableAllowance: user.enableAllowance, enableChores: user.enableChores, enableAdmin: user.isAdmin, enableTmdb: user.enableTmdb, tmdbKey: response!.sessionId) { (success, _) in
                if success {
                    KKidClient.getUsers(silent: true) { (_, _) in
                        ShowAlert.banner(theme: .success, title: "Account Linked", message: "Your TMDb account has been linked sucessfully to KKid user \(user.username!).")
                    }
                }
            }
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
}
