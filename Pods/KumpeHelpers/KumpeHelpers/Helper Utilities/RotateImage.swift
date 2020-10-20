//
//  CustomActivityIndicator.swift
//  On The Map
//
//  Created by Justin Kumpe on 7/25/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
// This class was copied in part from https://stackoverflow.com/questions/49666907/custom-image-with-rotation-in-activity-indicator-for-iphone-application-in-swift
// Written By Nazar Lisovyi

import Foundation
import UIKit


public class RotateImage {
    
    public static var activeView: UIView = UIView()

//    MARK: Start Rotating
//    Function accepts UIImageView and makes that image rotate
    public static func start(_ imageView: UIImageView) {
        imageView.isHidden = false
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        imageView.layer.add(rotation, forKey: "rotationAnimation")
    }

//    MARK: Stop Rotating
//    Function accepts UIImageView and makes that image stop rotating
    public static func stop(_ imageView: UIImageView, hideWhenStopped: Bool = true) {
         imageView.layer.removeAnimation(forKey: "rotationAnimation")
        if hideWhenStopped{
            imageView.isHidden = true
        }
    }
    
//    MARK: Rotate Function
//    Function accepts Bool and UIImageView them makes image rotate/stop rotating according to Bool
    public static func rotate(_ rotate: Bool, _ imageView: UIImageView, hideWhenStopped: Bool = true){
        if rotate{
            start(imageView)
        }else{
            stop(imageView, hideWhenStopped: hideWhenStopped)
        }
    }
}

public class Spinner: UIView {
    

    public let imageView = UIImageView()

    public init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)

        imageView.frame = bounds
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    public func startAnimating() {
        isHidden = false
        rotateImage()
    }

    public func stopAnimating() {
        isHidden = true
        removeRotationImage()
    }

    public func rotateImage() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imageView.layer.add(rotation, forKey: "rotationAnimation")
    }

    public func removeRotationImage() {
         self.imageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
}

public enum RoundType {
    case top
    case none
    case bottom
    case both
}

public extension UIView {

    func round(with type: RoundType, radius: CGFloat = 10.0) {
        var corners: UIRectCorner

        switch type {
        case .top:
            corners = [.topLeft, .topRight]
        case .none:
            corners = []
        case .bottom:
            corners = [.bottomLeft, .bottomRight]
        case .both:
            corners = [.allCorners]
        }

        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

}


public func activityIndicator(_ view: UIView, _ animate: Bool, _ indicatorActivity: Spinner){
    
    view.addSubview(indicatorActivity)
    
    indicatorActivity.center = view.center
    indicatorActivity.backgroundColor = UIColor.black
    indicatorActivity.alpha = 0.5
    indicatorActivity.round(with: .both)
    
    if animate{
        indicatorActivity.startAnimating()
    }else{
        indicatorActivity.stopAnimating()
    }
    
}

/*
//    MARK: Custom Activity Indicator
let indicatorActivity = Spinner(frame: CGRect(x: 0, y: 0, width: 100, height: 100), image: UIImage(named: "loading")!)
*/
