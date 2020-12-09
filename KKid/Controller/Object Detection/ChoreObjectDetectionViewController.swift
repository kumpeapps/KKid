//
//  ChoreObjectDetectionViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 12/6/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML
import KumpeHelpers

class ChoreObjectDetectionViewController: VisionObjectRecognitionViewController {

    // MARK: parameters
    var chore: Chore!

    // MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard chore.objectDetectionTag ?? "none" != "none" else {
            return
        }
        ShowAlert.centerView(theme: .info, title: "Object Detection", message: "Scanning of a \(chore.objectDetectionTag ?? "none") or similar object is required to check off this chore.", seconds: 3.00, invokeHaptics: false)
    }

    // MARK: processObject
    override func processObject(identifier: String, confidence: VNConfidence) {
        guard confidence >= 0.90 else {
            return
        }
        guard let chore = chore else {
            Logger.log(.error, "Chore Not Selected")
            return
        }
        guard let searchFor = chore.objectDetectionTag else {
            Logger.log(.error, "Object Detection Tag Empty")
            return
        }
        guard identifier == searchFor else {
            return
        }
    }

}
