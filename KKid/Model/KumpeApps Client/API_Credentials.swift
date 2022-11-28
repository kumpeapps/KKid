//
//  Credentials.swift
//  KKid
//
//  Created by Justin Kumpe on 9/26/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import Keys

struct APICredentials {

    let kkid: KKid

// MARK: KKid Credentials
    struct KKid {
        static let apikey = KKidKeys().kkid_apikey
    }

// MARK: ShipBook Creds
    struct ShipBook {
        static let appId = KKidKeys().shipBook_appId
        static let appKey = KKidKeys().shipBook_appKey
    }

// MARK: TMDB Creds
    struct TMDB {
        static let apikey = KKidKeys().tmdb_apiKey
    }

// MARK: Unsplash Creds
    struct Unsplash {
        static let access = KKidKeys().unsplash_accesskey
        static let secret = KKidKeys().unsplash_secretkey
    }

// MARK: NewRelic Creds
    struct NewRelic {
        static let apikey = KKidKeys().newrelic_token
    }
}
