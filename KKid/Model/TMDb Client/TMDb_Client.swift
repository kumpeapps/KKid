//
//  TMDb_Client.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import Foundation
import KumpeHelpers

class TMDb_Client: KumpeAPIClient {

// MARK: searchMovies
    class func searchMovies(query: String, page: Int, completion: @escaping (TMDb_Movie_Response?, String?) -> Void) {
        let parameters = [
            "api_key":"\(TMDb_Constants.apiKey)",
            "query":"\(query)",
            "include_adult":"false",
            "page":"\(page)"
        ]
        TMDb_Client.taskForGet(apiUrl: TMDb_Constants.searchMoviesUrl, responseType: TMDb_Movie_Response.self, parameters: parameters) { (response, error) in
            completion(response,error)
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
}
