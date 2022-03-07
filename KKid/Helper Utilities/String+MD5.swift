//
//  String+MD5.swift
//  KKid
//
//  Created by Justin Kumpe on 3/5/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
