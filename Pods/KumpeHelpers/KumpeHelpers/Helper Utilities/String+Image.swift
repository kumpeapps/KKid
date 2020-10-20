//
//  String+Image.swift
//  KKid
//
//  Created by Justin Kumpe on 9/12/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// Copied code from: https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage
//

import UIKit


extension String {
    
//    Creates image from string (like an emoji)
    public func image() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
