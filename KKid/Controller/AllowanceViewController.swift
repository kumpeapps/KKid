//
//  AllowanceViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/17/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//


import UIKit
import CoreData

class AllowanceViewController: UIViewController, NSFetchedResultsControllerDelegate{
    
//    MARK: Parameters
    var selectedUser: User!
    var allowanceData: KKid_AllowanceResponse?
    
//    MARK: Images
    @IBOutlet weak var imageBalance: UIImageView!
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
//    MARK: Buttons
    @IBOutlet weak var buttonLedger: UIBarButtonItem!
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
        
//    MARK: Reachability
    var reachable: ReachabilitySetup!
    
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        let image = Pathifier.makeImage(for: NSAttributedString(string: "$"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!)
        imageBalance.image = image
        getAllowance()
        verifyAuthenticated()
            NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
    }
            
//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        KKidClient.verifyIsAuthenticated(self)
    }
    
//    MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachable = nil
        NotificationCenter.default.removeObserver(self)
    }
    
//    MARK: getAllowance
    func getAllowance(){
        KKidClient.getAllowance(selectedUser: selectedUser) { (response, error) in
            if let response = response{
                self.allowanceData = response
                var balance = "\(response.balance)"
                if response.balance < 0{
                    balance.remove(at: balance.startIndex)
                    balance = "-$\(balance)"
                }else{
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
    
//    MARK: pressedLedger
    @IBAction func pressedLedger(){
        performSegue(withIdentifier: "segueAllowanceLedger", sender: self)
    }
    
//    MARK: pressedAdd
    @IBAction func pressedAdd(){
        performSegue(withIdentifier: "segueAddTransaction", sender: self)
    }
    
//    MARK: prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAllowanceLedger"{
            let viewController = segue.destination as! AllowanceLedgerViewController
            viewController.allowanceTransactions = self.allowanceData!.allowanceTransaction!
        }else if segue.identifier == "segueAddTransaction"{
            let viewController = segue.destination as! AllowanceAddTransactionViewController
            viewController.selectedUser = selectedUser
        }
    }
}

