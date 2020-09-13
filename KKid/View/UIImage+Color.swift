//
//  UIImage+Color.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
