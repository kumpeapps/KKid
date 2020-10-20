//
//  MarkChoreViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData
import KumpeHelpers
import Haptico

class MarkChoreViewController: UIViewController {

// MARK: Parameters
    var chore: Chore!
    var selectedUser: User!

// MARK: Buttons
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var buttonDash: UIButton!
    @IBOutlet weak var buttonX: UIButton!

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageLogo.image = AppDelegate().kkidLogo
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
//        Disable Dash Button if blockDash is set to true and user is not an Admin
        if chore.blockDash && !LoggedInUser.user!.isAdmin {
            buttonDash.isHidden = true
        }
//        Disable Dash and Check if chore is already marked as an X and user is not an Admin
        if chore.status == "x" && !LoggedInUser.user!.isAdmin {
            buttonDash.isHidden = true
            buttonCheck.isHidden = true
        }
    }

// MARK: viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

// MARK: verifyAuthenticated
    @objc func verifyAuthenticated() {
        KKidClient.verifyIsAuthenticated(self)
    }

// MARK: markChore
    @IBAction func markChore(sender: UIButton) {
        var status = ""

        switch sender.tag {
        case 1:
            status = "check"
        case 2:
            status = "dash"
        case 3:
            status = "x"
        default:
            status = "todo"
        }
        self.dismiss(animated: true, completion: nil)
        KKidClient.markChore(chore: chore!, choreStatus: status, user: selectedUser) { (success) in
            if success {
                let choreID = self.chore.objectID
                DataController.shared.backgroundContext.perform {
                    let backgroundChore = DataController.shared.backgroundContext.object(with: choreID) as! Chore
                    backgroundChore.status = status
                    try? DataController.shared.backgroundContext.save()
                }
                Haptico.shared().generate(.success)
            } else {
                ShowAlert.banner(title: "Error", message: "An unknown error occurred while trying to mark your chore status.")
            }

        }
    }

}
