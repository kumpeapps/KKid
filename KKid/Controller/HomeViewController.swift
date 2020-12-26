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
import Kingfisher
import DeviceKit
import KumpeHelpers
import Snowflake
import AVFoundation

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
    var modules: [KKid_Module] = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
    let dayOfWeek: Int = getDayOfWeek() ?? 0
    var choreCount: Int = 0
    let iconCache = ImageCache(name: "iconCache")

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        iconCache.diskStorage.config.expiration = .days(90)
        iconCache.memoryStorage.config.expiration = .days(90)
    }

// MARK: becomeFirstResponder
    override func becomeFirstResponder() -> Bool {
        return true
    }

// MARK: motionEnded (detect shake)
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            startSnowflake()
        }
    }

// MARK: startSnowFlake
    func startSnowflake() {
        let flake = #imageLiteral(resourceName: "icons8-winter")
        let snowflake = Snowflake(view: view, particles: [flake: .white])
        self.view.layer.addSublayer(snowflake)
        snowflake.start()
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        seasonalBackgroundLoader()
        if LoggedInUser.user == nil {
            LoggedInUser.setLoggedInUser()
        }

        if LoggedInUser.selectedUser == nil {
            LoggedInUser.setSelectedToLoggedIn()
        }

        choreCount = UIApplication.shared.applicationIconBadgeNumber
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(buildModules), name: .updateUser, object: nil)
        verifyAuthenticated()
        modules = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
        buildModules()
        registerAPNS()
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

        if LoggedInUser.user != nil && !LoggedInUser.user!.enableNoAds {
            loadGoogleAdMob()
        }

        self.requirePrivacy()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        reachable = nil
        iconCache.cleanExpiredCache()
        iconCache.cleanExpiredDiskCache()
    }

// MARK: didRecieveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        iconCache.clearMemoryCache()
    }

// MARK: verifyAuthenticated
    @objc func verifyAuthenticated() {
        guard UserDefaults.standard.bool(forKey: "isAuthenticated") else {
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
            collectionView.reloadData()
            performSegue(withIdentifier: "segueLogin", sender: self)
            LoggedInUser.user = nil
            LoggedInUser.selectedUser = nil
            return
        }
    }

// MARK: registerAPNS
    func registerAPNS() {

        guard let token = UserDefaults.standard.string(forKey: "apnsToken") else {
            return
        }

        guard token != "" else {
            return
        }

        KKidClient.registerAPNS(token)
    }

// MARK: buildModules
    @objc func buildModules() {
        if let selectedUser = LoggedInUser.selectedUser {
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
            if LoggedInUser.selectedUser == LoggedInUser.user {
                self.title = "\(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            } else {
                self.title = "Selected: \(selectedUser.emoji!) \(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
            }
            if selectedUser.enableChores {
                modules.append(KKid_Module.init(title: "Chores", segue: "segueChores", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-to-do-80.png"))
            }

            if selectedUser.enableAllowance {
                modules.append(KKid_Module.init(title: "Allowance", segue: "segueAllowance", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-receive-cash-80.png"))
            }

            if selectedUser.enableTmdb {
                modules.append(KKid_Module.init(title: "Search Movies", segue: "segueSearchMovies", icon: UIImage(named: "tmdb")!, getRemoteIcon: false, remoteIconName: nil))
            }

            if selectedUser.enableObjectDetection {
                modules.append(KKid_Module.init(title: "Detect Objects", segue: "segueObjectDetection", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-detective-50.png"))
            }

            modules.append(KKid_Module.init(title: "Edit Profile", segue: "segueEditProfile", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-profile-80.png"))

            if LoggedInUser.user!.isAdmin {
                modules.append(KKid_Module.init(title: "Select User", segue: "segueSelectUser", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-select-users-80.png"))
            }

            modules.append(KKid_Module.init(title: "App Settings", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-services-50.png"))

            modules.append(KKid_Module.init(title: "User Manual", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-user_manual-50.png"))

        }

        collectionView.reloadData()
    }

// MARK: pressedLogout
    func pressedLogout() {
        KKidClient.logout(userInitiated: true)
    }

// MARK: checkCamera
    func checkCamera(segue: String) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission(segue: segue)
        case .authorized: performSegue(withIdentifier: segue, sender: self)
        case .restricted, .denied: alertCameraAccessNeeded()
        @unknown default:
            fatalError()
        }
    }

    func requestCameraPermission(segue: String) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
            dispatchOnMain {
                self.performSegue(withIdentifier: segue, sender: self)
            }
        })
    }

    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!

        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to use Object Detection.",
            preferredStyle: UIAlertController.Style.alert
        )

       alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
       alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (_) -> Void in
           UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
       }))

       present(alert, animated: true, completion: nil)
   }

// MARK: centerItemsInCollectionView
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

// MARK: seasonalBackgroundLoader
    func seasonalBackgroundLoader() {
        if UserDefaults.standard.string(forKey: "seasonalBackgroundImage") == nil {
            UserDefaults.standard.set("default", forKey: "seasonalBackgroundImage")
        }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: now)
        let currentBackground = UserDefaults.standard.string(forKey: "seasonalBackgroundImage")
        switch nameOfMonth {
        case "December":
            if currentBackground != "Christmas" {
                downloadImage(URL(string: "\(KKidClient.imageURL)/backgrounds/christmas.jpg")!, isBackground: true)
                downloadImage(URL(string: "\(KKidClient.imageURL)/backgrounds/candycane.jpg")!, isBackground: false)
                UserDefaults.standard.set("Christmas", forKey: "seasonalBackgroundImage")
            }
        default:
            if currentBackground != "default" {
                setImage(UIImage(named: "photo2")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!), isBackground: false)
                UserDefaults.standard.set("default", forKey: "seasonalBackgroundImage")
            }
        }
        imageBackground.image = PersistBackgrounds.loadImage(isBackground: true)
        imageLogo.image = PersistBackgrounds.loadImage(isBackground: false)
    }

// MARK: downloadImage
    func downloadImage(_ url: URL, isBackground: Bool) {
        let downloader = ImageDownloader.default
        downloader.downloadImage(with: url, completionHandler: { result in
            switch result {
            case .success(let value):
                var image = value.image
                if !isBackground {
                    image = Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: value.image)
                }
                self.setImage(image, isBackground: isBackground)
            case .failure(let error):
                print(error)
            }
        })
    }

// MARK: setImage
    func setImage(_ image: UIImage, isBackground: Bool) {
        PersistBackgrounds.saveImage(image, isBackground: isBackground)
        imageBackground.image = PersistBackgrounds.loadImage(isBackground: true)
        imageLogo.image = PersistBackgrounds.loadImage(isBackground: false)
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
            cell.title.text = module.title
            cell.badge.text = "0"
            cell.badge.isHidden = true

            if module.getRemoteIcon && module.remoteIconName != nil {
                cell.imageView.kf.setImage(
                    with: URL(string: "\(KKidClient.imageURL)/\(module.remoteIconName!)"),
                    placeholder: module.icon,
                    options: [
                        .transition(.fade(1)),
                        .cacheOriginalImage,
                        .cacheSerializer(FormatIndicatedCacheSerializer.png),
                        .targetCache(iconCache)
                    ])
            } else {
                cell.imageView.image = module.icon
            }

            if module.title == "Chores" && choreCount > 0 {
                cell.badge.isHidden = false
                cell.badge.text = "\(choreCount)"
            }
            return cell
        }

    // MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let module = modules[indexPath.row]
            switch module.title {
            case "Logout":
                pressedLogout()
            case "Detect Objects":
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    checkCamera(segue: module.segue!)
                } else {
                    ShowAlert.banner(theme: .warning, title: "Oops", message: "Camera is required for this function. Your device does not have a camera or your camera is disabled.")
                }
            case "App Settings":
                let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            case "User Manual":
                launchURL("https://github.com/kumpeapps/KKid/blob/master/README.md")
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
