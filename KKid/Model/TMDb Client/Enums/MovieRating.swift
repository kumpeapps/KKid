//
//  MovieRating.swift
//  KKid
//
//  Created by Justin Kumpe on 11/29/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

enum MovieRating: String {

    case g
    case pg
    case pg13
    case r
    case nc17
    case unrated
    case nr
    case unknown

    var url: URL {
        switch self {

        case .g:
            return URL(string: "https://docs-assets.developer.apple.com/published/9d79d030fa/c128caf1-37d6-46a4-b4d4-5565d6c276b5.png")!
        case .pg:
            return URL(string: "https://docs-assets.developer.apple.com/published/34a821f19d/2683af80-daa8-42f5-b42b-cd8d18895c8a.png")!
        case .pg13:
            return URL(string: "https://docs-assets.developer.apple.com/published/49cf1e29a2/4402f353-2c70-4b87-bfc8-58ecaf37da1d.png")!
        case .r:
            return URL(string: "https://docs-assets.developer.apple.com/published/af070ae632/0a3cba09-3b00-4fe9-994f-56c3f48fdab4.png")!
        case .nc17:
            return URL(string: "https://docs-assets.developer.apple.com/published/4b995b1906/e2ed23c9-3ba1-4ce1-be91-6ad545de729a.png")!
        case .unrated:
            return URL(string: "https://docs-assets.developer.apple.com/published/28dbfae25d/de5ac777-b281-4056-80b1-b331a7c9a62f.png")!
        case .nr:
            return URL(string: "https://docs-assets.developer.apple.com/published/c943d3bf69/3a6dd956-11c1-4798-94a2-1cdd2c41fac0.png")!
        case .unknown:
            return URL(string: "https://docs-assets.developer.apple.com/published/c943d3bf69/3a6dd956-11c1-4798-94a2-1cdd2c41fac0.png")!
        }
    }

    var iosAllowedCode: Int {
        switch self {

        case .g:
            return 100
        case .pg:
            return 200
        case .pg13:
            return 300
        case .r:
            return 400
        case .nc17:
            return 500
        case .unrated:
            return 1
        case .nr:
            return 1
        case .unknown:
            return 1
        }
    }

    var iosMaxAllowed: Int {
        return UserDefaults.standard.object(forKey: "com.apple.content-rating.MovieRating") as? Int ?? 1000
    }
}
