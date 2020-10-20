//
//  Chore+Extensions.swift
//  KKid
//
//  Created by Justin Kumpe on 9/14/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import CoreData

extension Chore {
    public override func willSave() {
        super.willSave()
        setPrimitiveValue(Days(rawValue: day!)!.code, forKey: "dayAsNumber")
        //dayAsNumber = Days(rawValue: day!)!.code
    }

}
