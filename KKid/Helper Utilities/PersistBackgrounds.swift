//
//  SaveBackgrounds.swift
//  KKid
//
//  Created by Justin Kumpe on 9/7/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit


class SaveBackgrounds {
    
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

            } catch {
            print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
}
