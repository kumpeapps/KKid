//
//  AllowanceViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/17/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData
import KumpeHelpers

class AllowanceViewController: UIViewController, NSFetchedResultsControllerDelegate {

// MARK: Parameters
    var selectedUser = LoggedInUser.selectedUser!
    var allowanceData: KKid_AllowanceResponse?

// MARK: Images
    @IBOutlet weak var imageBalance: UIImageView!
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!

// MARK: Buttons
    @IBOutlet weak var buttonLedger: UIBarButtonItem!
    @IBOutlet weak var buttonAdd: UIBarButtonItem!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        imageLogo.image = PersistBackgrounds.loadImage(isBackground: false)
        imageBackground.image = PersistBackgrounds.loadImage(isBackground: true)
        let image = Pathifier.makeImage(for: NSAttributedString(string: "$"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!)
        imageBalance.image = image
        getAllowance()
        verifyAuthenticated()
            NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
    }

    // MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // tutorial()
    }

// MARK: verifyAuthenticated
    @objc func verifyAuthenticated() {
        KumpeAppsClient.verifyIsAuthenticated(self)
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachable = nil
        NotificationCenter.default.removeObserver(self)
    }

// MARK: getAllowance
    func getAllowance() {
        KumpeAppsClient.getAllowance(selectedUser: selectedUser) { (response, _) in
            if let response = response {
                self.allowanceData = response
                var balance = "\(response.balance)"
                if response.balance < 0 {
                    balance.remove(at: balance.startIndex)
                    balance = "-$\(balance)"
                } else {
                    balance = "$\(balance)"
                }
                dispatchOnMain {
                    let image = Pathifier.makeImage(for: NSAttributedString(string: balance), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!)
                    self.imageBalance.image = image
                    self.buttonLedger.isEnabled = !response.allowanceTransaction!.isEmpty
                }
            }
        }
    }

// MARK: pressedLedger
    @IBAction func pressedLedger() {
        performSegue(withIdentifier: "segueAllowanceLedger", sender: self)
    }

// MARK: pressedAdd
    @IBAction func pressedAdd() {
        performSegue(withIdentifier: "segueAddTransaction", sender: self)
    }

// MARK: prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAllowanceLedger"{
            let viewController = segue.destination as! AllowanceLedgerViewController
            guard self.allowanceData != nil else {
                ShowAlert.banner(title: "Error", message: "There was an error pulling allowance transactions. This could be because this user no longer exists. We recommend refreshing the user's page.")
                UserDefaults.standard.removeObject(forKey: "UserLastUpdated")
                return
            }
            viewController.allowanceTransactions = self.allowanceData!.allowanceTransaction!
        } else if segue.identifier == "segueAddTransaction"{
            let viewController = segue.destination as! AllowanceAddTransactionViewController
            viewController.selectedUser = selectedUser
        }
    }

}
