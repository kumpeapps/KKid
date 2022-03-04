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
        static let username = KKidKeys().kKid_username
        static let apiPassword = KKidKeys().kKid_apiPassword
        static let apikey = KKidKeys().kkid_apikey
    }

// MARK: Google AdMob Creds
    struct GoogleAdMob {
        static let homeScreenBannerID = KKidKeys().googleAdMob_homeScreenBannerID
    }

// MARK: ShipBook Creds
    struct ShipBook {
        static let appId = KKidKeys().shipBook_appId
        static let appKey = KKidKeys().shipBook_appKey
    }
}
