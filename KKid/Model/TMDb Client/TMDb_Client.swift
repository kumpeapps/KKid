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

}
