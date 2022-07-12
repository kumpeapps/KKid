//
//  WishListViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 10/24/2021.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import KumpeHelpers
import Haptico
import Toast_Swift
import ADEmptyDataView

class WishListViewController: UIViewController {

// MARK: Parameters
    let selectedUser = LoggedInUser.selectedUser

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!

// MARK: Buttons
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    @IBOutlet weak var buttonShare: UIBarButtonItem!

// MARK: Table View
    @IBOutlet weak var tableView: UITableView!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: Refresh Control
//    Adds functionality to swipe down to refresh table
    private let refreshControl = UIRefreshControl()

// MARK: fetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Wish>!

// MARK: setupFetchedResultsController
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Wish> = Wish.fetchRequest()
        let sortByPriority = NSSortDescriptor(key: "priority", ascending: true)
        let userPredicate = NSPredicate(format: "userID IN %@", [selectedUser!.userID])
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [userPredicate])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortByPriority]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "wishes")
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

        refreshWishes()

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshWishes), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Wishlist")
        refreshControl.endRefreshing()
        UserDefaults.standard.set(true, forKey: "Wish List")
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

// MARK: pressedAdd
    @IBAction func pressedAdd() {
        performSegue(withIdentifier: "segueAddWish", sender: self)
    }

// MARK: enableUI
    func enableUI(_ enable: Bool) {
        if enable {
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        } else {
            self.view.makeToastActivity(.center)
        }
        buttonAdd.isEnabled = enable
    }

// MARK: pressedShare
    @IBAction func pressedShare(_ sender: Any) {
        guard LoggedInUser.user!.isAdmin else {
            shareLink()
            return
        }
        let alert = UIAlertController(title: "Share Wish List", message: "Which List would you like to share?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: LoggedInUser.selectedUser!.firstName, style: .default , handler: { (_)in
            KumpeHelpers.Logger.log(.action, "Selected Share User")
            self.shareLink()
           }))

        alert.addAction(UIAlertAction(title: "Household (all users)", style: .destructive , handler: { (_)in
            KumpeHelpers.Logger.log(.action, "Selected Share Household")
            self.shareLink(user: LoggedInUser.user!, scope: .wishListAdmin)
           }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: { (_)in
            KumpeHelpers.Logger.log(.action, "Selected Cancel")
           }))

        // iPad Support
        if let popOverController = alert.popoverPresentationController {
            popOverController.sourceView = self.view
            popOverController.barButtonItem = self.buttonShare
        }

        KumpeHelpers.Logger.log(.action, "Prompting Admin for Share Selection")
           self.present(alert, animated: true, completion: {

           })

    }

    func shareLink(user: User = KKid.LoggedInUser.selectedUser!, scope: ShareLinkScope = .wishList) {
        KumpeAppsClient.getShareLink(selectedUser: user, scope: scope) { response, error in
            guard let authLink = response?.authLink else {
                KumpeHelpers.ShowAlert.messageView(theme: .error, title: "Error", message: error ?? "unknown error", invokeHaptics: true)
                return
            }
            KumpeHelpers.Share.url(authLink, self, shareButton: self.buttonShare)
            KumpeHelpers.Logger.log(.success, "Created Share Link")
        }
    }

}

    // MARK: - Table View

extension WishListViewController: UITableViewDataSource, UITableViewDelegate {

// MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

// MARK: tableView: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Load empty data view if table data is empty
        if fetchedResultsController.sections?[section].numberOfObjects ?? 0 == 0 {
            tableView.setEmptyDataView(image: UIImage(named: "empty_box")!, title: "No Items on your Wish List")
            tableView.backgroundColor = UIColor.lightGray
        } else {
            tableView.removeEmptyDataView()
            tableView.backgroundColor = UIColor.clear
        }
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

// MARK: tableView: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aWish = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure cell
        cell.textLabel?.text = "\(aWish.wishTitle ?? "")"
        cell.detailTextLabel?.text = "\(aWish.wishDescription ?? "")"
        let link = aWish.link ?? ""
        if link != "" {
            cell.imageView?.image = "🔗".image()
        } else {
            cell.imageView?.image = "🗒".image()
        }
        return cell
    }

// MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWish = fetchedResultsController.object(at: indexPath)
        let link = selectedWish.link ?? ""
        if link != "" {
            KumpeHelpers.launchURL(link)
        }
    }

// MARK: tableView: swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteWish(indexPath: indexPath)
        default: () // Unsupported
        }
    }

// MARK: deleteWish
    func deleteWish(indexPath: IndexPath) {
        let wish = fetchedResultsController.object(at: indexPath)
        KumpeAppsClient.deleteWish(wish) { (success, error) in
            if success {
                DataController.shared.viewContext.delete(wish)
                try? DataController.shared.viewContext.save()
                ShowAlert.statusLine(theme: .success, title: "Wish Deleted", message: "Wish Deleted", seconds: 5, dim: false)
            } else {
                ShowAlert.banner(title: "Delete Error", message: error ?? "An unknown error occurred.")
            }
        }
    }

// MARK: refreshWishes
    @objc func refreshWishes() {
        KumpeAppsClient.getWishes { (_, _) in
            dispatchOnMain {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension WishListViewController: NSFetchedResultsControllerDelegate {

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
