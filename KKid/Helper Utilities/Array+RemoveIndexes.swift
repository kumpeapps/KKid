//
//  Array+RemoveIndexes.swift
//  KKid
//
//  Created by Justin Kumpe on 11/29/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

extension Array {
    mutating func remove(at indexes: [Int]) {
        var lastIndex: Int?
        for index in indexes.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}
