//
//  getDayOfWeek.swift
//  KKid
//
//  Created by Justin Kumpe on 11/5/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

public func getDayOfWeek() -> Int? {
    let calendar = Calendar.current
    let date = Date()
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let today = "\(year)-\(month)-\(day)"
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let todayDate = formatter.date(from: today) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    return weekDay
}
