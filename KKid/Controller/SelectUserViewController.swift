//
//  SelectUserViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData

class SelectUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

//    MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
//    MARK: Buttons
    @IBOutlet weak var buttonLogout: UIBarButtonItem!
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    
//    MARK: Table View
    @IBOutlet weak var tableView: UITableView!
    
//    MARK: fetchedResultsController
    var fetchedResultsController:NSFetchedResultsController<User>!
    
/*    MARK: Refresh Control
    Adds functionality to swipe down to refresh table
*/
    private let refreshControl = UIRefreshControl()
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "isMaster", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "users")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    //    MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        tableView.delegate = self
        tableView.dataSource = self
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        enableUI(false)
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
    }
    
//    MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else{
            Logger.log(.warning, "Not Authenticated")
            return
        }
        
        KKidClient.getUsers( completion: { (success, error) in
            Logger.log(.success, "getUsers Completed")
            self.tableView.reloadData()
        })
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshUsers), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Users")
        refreshControl.endRefreshing()
    }
    
//    MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        fetchedResultsController = nil
    }

//    MARK: verifyAuthenticated
    @objc func verifyAuthenticated(){
        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else{
            performSegue(withIdentifier: "segueLogin", sender: self)
            return
        }
        enableUI(true)
    }
    
//    MARK: pressedLogout
    @IBAction func pressedLogout(){
        enableUI(false)
        KKidClient.logout(userInitiated: true)
    }
    
    
//    MARK: enableUI
    func enableUI(_ enable: Bool){
        if enable{
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        }else{
            self.view.makeToastActivity(.center)
        }
        buttonLogout.isEnabled = enable
        if UserDefaults.standard.bool(forKey: "isAdmin"){
            buttonAdd.isEnabled = enable
        }else{
            buttonAdd.isEnabled = false
        }
    }
    
    // MARK: - Table view data source

//    MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

//    MARK: tableView: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

//    MARK: tableView: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aUser = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure cell
        cell.textLabel?.text = "\(aUser.firstName ?? "") \(aUser.lastName ?? "")"
        
        if aUser.isBanned{
            cell.imageView?.image = altImage.banned.image
        }else if aUser.isLocked{
            cell.imageView?.image = altImage.locked.image
        }else if !aUser.isActive{
            cell.imageView?.image = altImage.inactive.image
        }else{
            cell.imageView?.image = aUser.emoji!.image()
        }
        
        if aUser.isMaster{
            cell.backgroundColor = UIColor.systemPurple
            cell.textLabel?.textColor = UIColor.white
        } else if aUser.isAdmin{
            cell.backgroundColor = UIColor.systemYellow
            cell.textLabel?.textColor = UIColor.black
        } else if aUser.isChild{
            cell.backgroundColor = UIColor.systemTeal
            cell.textLabel?.textColor = UIColor.black
        } else if !aUser.isActive{
            cell.backgroundColor = UIColor.systemRed
            cell.textLabel?.textColor = UIColor.black
        }
        
        
        enum altImage{
            case locked
            case banned
            case inactive
            
            var image: UIImage{
                switch self{
                case .locked: return "🔒".image()!
                case .banned: return "⛔️".image()!
                case .inactive: return "❗️".image()!
                }
            }
        }
        return cell
    }
    
//    MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = fetchedResultsController.object(at: indexPath)
        let loggedInUser = LoggedInUser.user!
        
        if selectedUser.isBanned{
            ShowAlert.banner(title: "User Banned", message: "This user has been banned. Please contact support at helpdesk@kumpeapps.com!")
        }else if selectedUser.isLocked{
            ShowAlert.banner(theme: .warning, title: "User Account Locked", message: "This user's account has been locked. You can still edit this account but the user can not login until their account is unlocked.")
//            TODO: perform segue to select module
        }else if !selectedUser.isActive{
            ShowAlert.banner(title: "Account Inactive", message: "This account is inactive. Please delete user or contact support at helpdesk@kumpeapps.com")
        }else if selectedUser.isMaster && !loggedInUser.isMaster{
            ShowAlert.banner(title: "Action Not Allowed", message: "Only the master account can select this user!")
        }else if selectedUser.userID != loggedInUser.userID && !loggedInUser.isAdmin{
            ShowAlert.banner(title: "Action Not Allowed", message: "Only Admin users may select other users. Please select your name only!")
        }else{
//            TODO: perform segue to select module
            ShowAlert.banner(theme: .warning, title: "Not Implemented", message: "Can not select user \(selectedUser.firstName ?? "Unknown User") yet!")
        }
    }

//    MARK: tableView: swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteUser(at: indexPath)
        default: () // Unsupported
        }
    }
    
//    MARK: deleteUser
    func deleteUser(at: IndexPath){
        if LoggedInUser.user!.isAdmin{
            let deleteUser = fetchedResultsController.object(at: at)
            ShowAlert.banner(theme: .warning, title: "Not Implemented", message: "Can not delete \(deleteUser.firstName ?? "No Name") yet.")
        }else{
            ShowAlert.banner(title: "Not Admin", message: "Only Admins can delete users. Sorry!")
        }
    }
    
//    MARK: refreshUsers
    @objc func refreshUsers(){
        KKidClient.getUsers { (success, error) in
            self.refreshControl.endRefreshing()
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SelectUserViewController:NSFetchedResultsControllerDelegate {
    
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
