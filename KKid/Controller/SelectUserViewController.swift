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
import AvatarView
import Kingfisher
import CollectionViewCenteredFlowLayout

class SelectUserViewController: UIViewController {

// MARK: Images
    @IBOutlet weak var imageBackground: UIImageView!

// MARK: Buttons
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!

// MARK: Collection View
    @IBOutlet weak var collectionView: UICollectionView!

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
        // fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SettingsBundleHelper.checkAndExecuteSettings()
        reachable = ReachabilitySetup()
        setupFetchedResultsController()
        collectionView.delegate = self
        collectionView.dataSource = self

/*        Pull logo and background from AppDelegate.
         Setup this way so users can choose their own background and logo style in future releases
 */
        imageBackground.image = PersistBackgrounds.loadImage(isBackground: true)

        enableUI(false)
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()

        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        navigationController?.setNavigationBarHidden(true, animated: animated)
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

        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()

        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshUsers), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Users")
        refreshControl.endRefreshing()
    }

    // MARK: Set collection view to isEditing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        buttonAdd.isHidden = editing
        buttonCancel.isHidden = !editing
        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! ModuleCollectionViewCell
            cell.isInEditingMode = editing
            cell.watermark.isHidden = !editing
            cell.avatarView.isHidden = editing
        }
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        fetchedResultsController = nil
        reachable = nil
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

    // MARK: pressedCancel
    @IBAction func pressedCancel(_ sender: Any) {
        setEditing(false, animated: true)
    }

    // MARK: longPress
    @IBAction func longPress(_ sender: Any) {
        setEditing(true, animated: true)
    }

    // MARK: enableUI
    func enableUI(_ enable: Bool) {
        if enable {
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        } else {
            self.view.makeToastActivity(.center)
        }
    }

}

    // MARK: - Table View

extension SelectUserViewController: UICollectionViewDataSource, UICollectionViewDelegate {

// MARK: userSelected
    func userSelected(selectedUser: User) {
        LoggedInUser.selectedUser = selectedUser
        self.navigationController?.popToRootViewController(animated: true)
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
                            dispatchOnMain {
                                self.collectionView.reloadData()
                            }
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
            }
        }
    }

// MARK: - CollectionView

// MARK: centerItemsInCollectionView
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

// MARK: Set Number of Items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

// MARK: Build Items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aUser = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell

        // Configure cell
        cell.title.text = "\(aUser.firstName ?? "") \(aUser.lastName?.prefix(1) ?? "")"

        if aUser.isMaster {
            cell.avatarView.borderColor = UIColor.systemPurple
        } else if aUser.isAdmin {
            cell.avatarView.borderColor = UIColor.systemYellow
        } else if aUser.isChild {
            cell.avatarView.borderColor = UIColor.systemTeal
        } else if !aUser.isActive {
            cell.avatarView.borderColor = UIColor.systemRed
        }

        let email = aUser.email!
        let gravatar = "https://www.gravatar.com/avatar/\(email.MD5)?d=mp"
        let delete = "https://img.icons8.com/external-tanah-basah-basic-outline-tanah-basah/48/000000/external-delete-user-user-tanah-basah-basic-outline-tanah-basah.png"
        cell.avatarView.isHidden = false
            cell.avatarView.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
            cell.avatarView.borderWidth = 4
            cell.imageView.image = nil
            cell.avatarView.backgroundColor = UIColor(white: 1, alpha: 0)
        cell.avatarView.imageView.kf.setImage(
            with: URL(string: gravatar),
            placeholder: UIImage(named: "mp"),
            options: [
                .transition(.fade(1)),
                .targetCache(ImageCache(name: "gravatarCache"))
                ])
        cell.watermark.kf.setImage(
            with: URL(string: delete),
            options: [
                .transition(.fade(1)),
                .targetCache(ImageCache(name: "iconCache"))
                ])
        cell.isInEditingMode = isEditing
        return cell
    }

// MARK: Did Select Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUser = fetchedResultsController.object(at: indexPath)
        let loggedInUser = LoggedInUser.user!
        guard !isEditing else {
            deleteUser(indexPath: indexPath)
            return
        }
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
}

// MARK: - Collection View Flow Layout Delegate
extension SelectUserViewController: UICollectionViewDelegateFlowLayout {
// MARK: set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = 150
        return CGSize(width: screenWidth, height: screenWidth)
    }
}
