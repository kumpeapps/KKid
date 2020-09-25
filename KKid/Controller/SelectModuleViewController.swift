//
//  SelectModuleViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData

class SelectModuleViewController: UIViewController{
    
//    MARK: Parameters
    var selectedUser:User?
    
//    MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
//    MARK: Table View
    @IBOutlet weak var tableView: UITableView!
        
    //    MARK: Reachability
        var reachable: ReachabilitySetup!
    
//    MARK: modules array
    var modules:[String] = ["Edit Profile"]
    
    
//    MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = selectedUser{
            if user.enableChores{
                modules.append("Chores")
            }
            if user.enableAllowance{
                modules.append("Allowance")
            }
            tableView.reloadData()
        }
    }
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        verifyAuthenticated()
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
    }
    
//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        KKidClient.verifyIsAuthenticated(self)
    }
    
//    MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
//    MARK: viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachable = nil
        NotificationCenter.default.removeObserver(self)
    }
    


    //    MARK: prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueChores"{
            let viewController = segue.destination as! ChoresViewController
            viewController.selectedUser = selectedUser
        }else if segue.identifier == "segueAllowance"{
            let viewController = segue.destination as! AllowanceViewController
            viewController.selectedUser = selectedUser
        }else if segue.identifier == "segueEditProfile"{
            let viewController = segue.destination as! UserEditProfileViewController
            viewController.selectedUser = selectedUser
        }
    }
}

//      MARK: - Table View Delegates

extension SelectModuleViewController: UITableViewDataSource, UITableViewDelegate{

//    MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    MARK: tableView: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules.count
    }

//    MARK: tableView: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let module = self.modules[indexPath.row]
        cell.textLabel?.text = module
        return cell
    }
    
//    MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let module = self.modules[indexPath.row]
        
        switch module {
        case "Chores":
            performSegue(withIdentifier: "segueChores", sender: self)
        case "Allowance":
            performSegue(withIdentifier: "segueAllowance", sender: self)
        case "Edit Profile":
        performSegue(withIdentifier: "segueEditProfile", sender: self)
        default:
            return
        }
    }

}


// MARK: - NSFetchedResultsControllerDelegate

extension SelectModuleViewController:NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            break
        }
    }
    
}
