//
//  SelectUserViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import KumpeHelpers
import Haptico
import Toast_Swift

class SelectUserViewController: UIViewController {

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!

// MARK: Buttons
    @IBOutlet weak var buttonAdd: UIBarButtonItem!

// MARK: Table View
    @IBOutlet weak var tableView: UITableView!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: Refresh Control
//    Adds functionality to swipe down to refresh table
    private let refreshControl = UIRefreshControl()

// MARK: fetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<User>!

// MARK: setupFetchedResultsController
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sortByMaster = NSSortDescriptor(key: "isMaster", ascending: false)
        let sortByAdmin = NSSortDescriptor(key: "isAdmin", ascending: false)
        let sortByFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortByMaster, sortByAdmin, sortByFirstName]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "users")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        setupFetchedResultsController()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self

/*        Pull logo and background from AppDelegate.
         Setup this way so users can choose their own background and logo style in future releases
 */
        imageLogo.image = PersistBackgrounds.loadImage(isBackground: false)
        imageBackground.image = PersistBackgrounds.loadImage(isBackground: true)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        enableUI(false)
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
    }

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else {
            Logger.log(.warning, "Not Authenticated")
            return
        }

        if UserDefaults.standard.value(forKey: "UserLastUpdated") == nil || !Calendar.current.isDateInToday(UserDefaults.standard.value(forKey: "UserLastUpdated") as! Date) {
            refreshUsers()
        }

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshUsers), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Users")
        refreshControl.endRefreshing()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        fetchedResultsController = nil
        reachable = nil
    }

// MARK: verifyAuthenticated
    @objc func verifyAuthenticated() {
        KumpeAppsClient.verifyIsAuthenticated(self)
        enableUI(true)
    }

// MARK: pressedLogout
    @IBAction func pressedLogout() {
        enableUI(false)
        KumpeAppsClient.logout(userInitiated: true)
    }

// MARK: pressedAdd
    @IBAction func pressedAdd() {
        performSegue(withIdentifier: "segueAddUser", sender: self)
    }

// MARK: enableUI
    func enableUI(_ enable: Bool) {
        if enable {
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        } else {
            self.view.makeToastActivity(.center)
        }

        if UserDefaults.standard.bool(forKey: "isAdmin") {
            buttonAdd.isEnabled = enable
        } else {
            buttonAdd.isEnabled = false
        }
    }

}

    // MARK: - Table View

extension SelectUserViewController: UITableViewDataSource, UITableViewDelegate {

// MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

// MARK: tableView: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

// MARK: tableView: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aUser = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure cell
        cell.textLabel?.text = "\(aUser.firstName ?? "") \(aUser.lastName ?? "")"

        if aUser.isBanned {
            cell.imageView?.image = AltImage.banned.image
        } else if aUser.isLocked {
            cell.imageView?.image = AltImage.locked.image
        } else if !aUser.isActive {
            cell.imageView?.image = AltImage.inactive.image
        } else {
            cell.imageView?.image = aUser.emoji!.image()
        }

        if aUser.isMaster {
            cell.backgroundColor = UIColor.systemPurple
            cell.textLabel?.textColor = UIColor.white
        } else if aUser.isAdmin {
            cell.backgroundColor = UIColor.systemYellow
            cell.textLabel?.textColor = UIColor.black
        } else if aUser.isChild {
            cell.backgroundColor = UIColor.systemTeal
            cell.textLabel?.textColor = UIColor.black
        } else if !aUser.isActive {
            cell.backgroundColor = UIColor.systemRed
            cell.textLabel?.textColor = UIColor.black
        }

        enum AltImage {
            case locked
            case banned
            case inactive

            var image: UIImage {
                switch self {
                case .locked: return "🔒".image()!
                case .banned: return "⛔️".image()!
                case .inactive: return "❗️".image()!
                }
            }
        }
        return cell
    }

// MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = fetchedResultsController.object(at: indexPath)
        let loggedInUser = LoggedInUser.user!

        if selectedUser.isBanned {
            ShowAlert.banner(title: "User Banned", message: "This user has been banned. Please contact support at helpdesk@kumpeapps.com!")
        } else if selectedUser.isLocked {
            ShowAlert.banner(theme: .warning, title: "User Account Locked", message: "This user's account has been locked. You can still edit this account but the user can not login until their account is unlocked.")
            userSelected(selectedUser: selectedUser)
        } else if !selectedUser.isActive {
            ShowAlert.banner(title: "Account Inactive", message: "This account is inactive. Please delete user or Add Permissions in Profile.")
            userSelected(selectedUser: selectedUser)
        } else if selectedUser.isMaster && !loggedInUser.isMaster {
            ShowAlert.banner(title: "Action Not Allowed", message: "Only the master account can select this user!")
        } else if selectedUser.userID != loggedInUser.userID && !loggedInUser.isAdmin {
            ShowAlert.banner(title: "Action Not Allowed", message: "Only Admin users may select other users. Please select your name only!")
        } else {
            userSelected(selectedUser: selectedUser)
        }
    }

// MARK: userSelected
    func userSelected(selectedUser: User) {
        LoggedInUser.selectedUser = selectedUser
        self.navigationController?.popToRootViewController(animated: true)
    }

// MARK: tableView: swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteUser(indexPath: indexPath)
        default: () // Unsupported
        }
    }

// MARK: deleteUser
    func deleteUser(indexPath: IndexPath) {
        if LoggedInUser.user!.isAdmin {
            let deleteUser = fetchedResultsController.object(at: indexPath)

            guard deleteUser != LoggedInUser.selectedUser else {
                ShowAlert.banner(title: "Delete Error", message: "You can not delete the selected user. Please select yourself or another user before deleting this user.")
                return
            }

            if let sections = fetchedResultsController.sections?.count, let section0Rows = fetchedResultsController.sections?[0].numberOfObjects, (sections == 1 && section0Rows == 1) || !deleteUser.isMaster {

                ShowAlert.choiceMessage(theme: .error, title: "Delete User???", message: "Tap outside of this message to cancel.") { _ in
                    KumpeAppsClient.deleteUser(deleteUser) { (success, error) in
                        if success {
                            DataController.shared.viewContext.delete(deleteUser)
                            try? DataController.shared.viewContext.save()
                            ShowAlert.statusLine(theme: .success, title: "User Deleted", message: "User Deleted", seconds: 5, dim: false)
                        } else {
                            ShowAlert.banner(title: "Delete Error", message: error ?? "An unknown error occurred.")
                        }
                    }
                }
            } else {
                ShowAlert.banner(theme: .error, title: "Error", message: "Other users exist. The master user can only be deleted if no other users exist under this account. Please delete all other users first!", seconds: 20)
            }
        } else {
            ShowAlert.banner(title: "Not Admin", message: "Only Admins can delete users. Sorry!")
        }
    }

// MARK: refreshUsers
    @objc func refreshUsers() {
        KumpeAppsClient.getUsers { (_, _) in
            dispatchOnMain {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SelectUserViewController: NSFetchedResultsControllerDelegate {

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
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
            tableView.setNeedsLayout()
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
