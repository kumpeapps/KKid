//
//  GCDBlackBox.swift
//  KKid
//
//  Created by Justin Kumpe on 8/17/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation

// MARK: Dispatch on Main

public func dispatchOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

// MARK: Dispatch on Background
public func dispatchOnBackground(_ updates: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
        updates()
    }
    
    
}
