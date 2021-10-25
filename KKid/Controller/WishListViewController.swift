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

class WishListViewController: UIViewController {

// MARK: Parameters
    let selectedUser = LoggedInUser.selectedUser
    
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
        // performSegue(withIdentifier: "segueAddWish", sender: self)
        KumpeHelpers.DebugHelpers.notImplementedBanner()
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

}

    // MARK: - Table View

extension WishListViewController: UITableViewDataSource, UITableViewDelegate {

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
        let aWish = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure cell
        cell.textLabel?.text = "\(aWish.wishTitle ?? "")"
        cell.detailTextLabel?.text = "\(aWish.wishDescription ?? "")"
        let link = aWish.link ?? ""
        if link != "" {
            cell.imageView?.image = "🔗".image()
        }
        return cell
    }

// MARK: tableView: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWish = fetchedResultsController.object(at: indexPath)
        let link = selectedWish.link ?? ""
        if link != "" {
            KumpeHelpers.DebugHelpers.notImplementedBanner()
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
