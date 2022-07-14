//
//  ShareLinkScope.swift
//  KKid
//
//  Created by Justin Kumpe on 7/6/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import Foundation

enum ShareLinkScope: String {

    case wishList
    case wishListAdmin
    case chores
    case choresAdmin

    var link: String {
        switch self {
        case .wishList, .wishListAdmin: return "https://khome.kumpeapps.com/portal/wish-list.php"
        case .chores, .choresAdmin: return "https://khome.kumpeapps.com/portal/chores-today.php"
        }
    }

    var name: String {
        switch self {
        case .wishList: return "WishList"
        case .wishListAdmin: return "WishListAdmin"
        case .chores: return "Chores"
        case .choresAdmin: return "ChoresAdmin"
        }
    }
}
