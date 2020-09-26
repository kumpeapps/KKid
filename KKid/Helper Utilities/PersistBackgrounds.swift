//
//  PersistBackgrounds.swift
//  KKid
//
//  Created by Justin Kumpe on 9/7/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//
//Saves/loads images to/from device. Will use this in future release so users can setup custom backgrounds/logos.

import UIKit


class PersistBackgrounds {
    
//    MARK: saveImage
    class func saveImage(_ image: UIImage, isBackground: Bool){
        
        var imageName = "background.png"
        
        if !isBackground{
            imageName = "logo.png"
        }
        
        // Convert to Data
        if let data = image.pngData() {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(imageName)

            do {
                // Write to Disk
                try data.write(to: url)
                Logger.log(.action, "\(imageName) saved to \(url)")

            } catch {
            print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
    
//    MARK: loadImage
    class func loadImage(isBackground: Bool) -> UIImage? {

        var imageName = "background.png"
        
        if !isBackground{
            imageName = "logo.png"
        }
        
      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(imageName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }
}
