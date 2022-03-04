//
//  Days.swift
//  KKid
//
//  Created by Justin Kumpe on 9/15/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

enum Days: String {

    case Weekly
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday

    var code: Int16 {
        switch self {
        case .Weekly: return 8
        case .Sunday: return 1
        case .Monday: return 2
        case .Tuesday: return 3
        case .Wednesday: return 4
        case .Thursday: return 5
        case .Friday: return 6
        case .Saturday: return 7
        }
    }
}
