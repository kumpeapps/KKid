//
//  HomeViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 10/5/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

// @todo: Enhancement- Add What's New Page
// @body: Add what's new page to modules and have it launch on app update

import UIKit
import CollectionViewCenteredFlowLayout
import GoogleMobileAds
import PrivacyKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PrivacyKitDelegate {

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!

// MARK: Google Add Banner
    @IBOutlet var bannerView: GADBannerView!

// MARK: Collection View
    @IBOutlet weak var collectionView: UICollectionView!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: Parameters
    var modules: [KKid_Module] = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reachable = ReachabilitySetup()
        imageLogo.image = AppDelegate().kkidLogo
        imageBackground.image = AppDelegate().kkidBackground
        if LoggedInUser.user == nil {
            LoggedInUser.setLoggedInUser()
        }

        if LoggedInUser.selectedUser == nil {
            LoggedInUser.setSelectedToLoggedIn()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        verifyAuthenticated()
        modules = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
        buildModules()

    }

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "UserLastUpdated") == nil || !Calendar.current.isDateInToday(UserDefaults.standard.value(forKey: "UserLastUpdated") as! Date) {
            KKidClient.getUsers { (_, _) in
                LoggedInUser.setLoggedInUser()
                self.buildModules()
            }
        }

        if !LoggedInUser.user!.enableNoAds {
            loadGoogleAdMob()
        }
        self.requirePrivacy()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        reachable = nil
    }

// MARK: verifyAuthenticated
    @objc func verifyAuthenticated() {
        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else {
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
            collectionView.reloadData()
            performSegue(withIdentifier: "segueLogin", sender: self)
            LoggedInUser.user = nil
            LoggedInUser.selectedUser = nil
            return
        }
    }

// MARK: buildModules
    func buildModules() {
        if let selectedUser = LoggedInUser.selectedUser {
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: #imageLiteral(resourceName: "logout-1"))]
            if LoggedInUser.selectedUser == LoggedInUser.user {
                self.title = "\(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            } else {
                self.title = "Selected: \(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            }
            if selectedUser.enableChores {
                modules.append(KKid_Module.init(title: "Chores", segue: "segueChores", icon: #imageLiteral(resourceName: "chores")))
            }

            if selectedUser.enableAllowance {
                modules.append(KKid_Module.init(title: "Allowance", segue: "segueAllowance", icon: #imageLiteral(resourceName: "allowance")))
            }

            modules.append(KKid_Module.init(title: "Edit Profile", segue: "segueEditProfile", icon: #imageLiteral(resourceName: "profile")))

            if LoggedInUser.user!.isAdmin {
                modules.append(KKid_Module.init(title: "Select User", segue: "segueSelectUser", icon: #imageLiteral(resourceName: "select_user")))
            }
        }

        collectionView.reloadData()
    }

// MARK: pressedLogout
    func pressedLogout() {

        KKidClient.logout(userInitiated: true)
    }

// MARK: centerItemsInCollectionView
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

}

// MARK: - Collection View Functions
extension HomeViewController {

    // MARK: Set Number of Items
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return modules.count
        }

    // MARK: Build Items
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let module = modules[(indexPath as NSIndexPath).row]

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell
            cell.imageView.image = module.icon
            cell.title.text = module.title
            return cell
        }

    // MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let module = modules[indexPath.row]
            switch module.title {
            case "Logout":
                pressedLogout()
            default:
                performSegue(withIdentifier: module.segue!, sender: self)
            }
        }
}

// MARK: - Collection View Flow Layout Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout {
// MARK: set cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = 100
        return CGSize(width: screenWidth, height: screenWidth)
    }
}

// MARK: - Google AdBanner
extension HomeViewController: GADBannerViewDelegate {
    func loadGoogleAdMob() {
        bannerView.adUnitID = APICredentials.GoogleAdMob.homeScreenBannerID

        #if DEBUG
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #endif

        bannerView.rootViewController = self
        bannerView.load(GADRequest())
          }

}
