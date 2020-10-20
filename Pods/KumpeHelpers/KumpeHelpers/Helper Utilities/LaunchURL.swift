//
//  LaunchURL.swift
//  KKid
//
//  Created by Justin Kumpe on 7/25/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit

// MARK: Launch URL
public func launchURL(_ urlString: String?) -> Void {
    if let urlString = urlString, let url = URL(string: urlString) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
