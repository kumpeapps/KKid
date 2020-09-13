//
//  SelectModuleViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit

class SelectModuleViewController: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "segueChores", sender: self)
    }
}
