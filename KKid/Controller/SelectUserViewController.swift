//
//  ViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageLogo: UIImageView!
    
    @IBOutlet weak var imageBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLogo.image = AppDelegate().kkidLogo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //let kkidText:NSAttributedString = NSAttributedString(string: "KKID")
        
        //let KKID = Pathifier.makeImage(for: kkidText, withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .red)!)
        
        //imageKKID.image = KKID
        
    }

}

