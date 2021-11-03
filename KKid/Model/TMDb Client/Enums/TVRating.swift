//
//  MovieRating.swift
//  KKid
//
//  Created by Justin Kumpe on 11/29/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

enum TVRating: String {

    case tvy
    case tvy7
    case tvy7fv
    case tvg
    case tvpg
    case tv14
    case tvma
    case unknown

    var url: URL {
        switch self {

        case .tvy:
            return URL(string: "https://docs-assets.developer.apple.com/published/aca0876cf5a21f3e040d281e88fa329c/6100/television-rating-icons-united-states-1@2x.png")!
        case .tvy7:
            return URL(string: "https://docs-assets.developer.apple.com/published/a039e8de5e4cd3d41f3408ba738bf958/6100/television-rating-icons-united-states-2@2x.png")!
        case .tvy7fv:
            return URL(string: "https://docs-assets.developer.apple.com/published/8ab4ffb16dc3620a098afb501300dce0/6100/television-rating-icons-united-states-3@2x.png")!
        case .tvg:
            return URL(string: "https://docs-assets.developer.apple.com/published/c1c48434c750c55f360fd491cfea1f09/6100/television-rating-icons-united-states-4@2x.png")!
        case .tvpg:
            return URL(string: "https://docs-assets.developer.apple.com/published/0ab869b0fe4c2060d1be5c126bfe6a0a/6100/television-rating-icons-united-states-5@2x.png")!
        case .tv14:
            return URL(string: "https://docs-assets.developer.apple.com/published/0d52130e9990e08138ca2723d72d29d2/6100/television-rating-icons-united-states-6@2x.png")!
        case .tvma:
            return URL(string: "https://docs-assets.developer.apple.com/published/e5f7f9c7b4b6c8ea3477d75fae30e815/6100/television-rating-icons-united-states-7@2x.png")!
        case .unknown:
            return URL(string: "https://docs-assets.developer.apple.com/published/c943d3bf69/3a6dd956-11c1-4798-94a2-1cdd2c41fac0.png")!
        }
    }
}
