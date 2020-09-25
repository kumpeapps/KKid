//
//  ChoreStatus.swift
//  KKid
//
//  Created by Justin Kumpe on 9/14/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit

enum ChoreStatus: String {
    
    case check
    case oCheck
    case todo
    case todoOptional
    case x
    case dash
    case stolen
    case Calendar
    case calendar
    
    var image: UIImage{
        switch self{
        case .check, .oCheck, .stolen: return UIImage(named: "green_check")!
        case .x: return UIImage(named: "red_x")!
        case .dash: return UIImage(named: "blue_dash")!
        case .calendar, .Calendar: return "🗓".image()!
        default :return "📝".image()!
        }
    }
    
}
