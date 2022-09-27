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
import PrivacyKit
import Kingfisher
import DeviceKit
import KumpeHelpers
import Snowflake
import WhatsNew
import AvatarView
import iCloudSync

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PrivacyKitDelegate {

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var avatarView: AvatarView!

// MARK: Buttons
    @IBOutlet weak var avatarButton: UIButton!

// MARK: Collection View
    @IBOutlet weak var collectionView: UICollectionView!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: Labels
    @IBOutlet weak var labelSwitchUser: UILabel!

    // MARK: Timer
    var timer: Timer?

// MARK: Parameters
    var modules: [KKid_Module] = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
    let dayOfWeek: Int = getDayOfWeek() ?? 0
    var choreCount: Int = 0
    let iconCache = ImageCache(name: "iconCache")
    let gravatarCache = ImageCache(name: "gravatarCache")
    var isKiosk: Bool = false
    var userSelected: Bool = false

// MARK: WhatsNew Parameters
    let whatsNew = WhatsNewViewController(items: [
        WhatsNewItem.text(title: "Kiosk Mode", subtitle: "Added Kiosk Mode")])

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //        Load Data Controller
        DataController.shared.load()
        //        Initiate DataController Autosave
        DataController.shared.autoSaveViewContext()
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CollectionViewCenteredFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
        iconCache.diskStorage.config.expiration = .days(90)
        iconCache.memoryStorage.config.expiration = .days(90)
        gravatarCache.diskStorage.config.expiration = .seconds(500)
        gravatarCache.memoryStorage.config.expiration = .seconds(500)
        avatarView.imageView.isUserInteractionEnabled = false
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
        let snowflake1 = UIImage(named: "icons8-winter")!
        let snowflake = Snowflake(view: view, particles: [snowflake1: .white])
        self.view.layer.addSublayer(snowflake)
        snowflake.start()
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isKiosk = UserDefaults.standard.bool(forKey: "enableKiosk")
        self.userSelected = UserDefaults.standard.bool(forKey: "userSelected")
        imageLogo.imageFromiCloud(imageName: "logo", waitForUpdate: false)
        imageBackground.imageFromiCloud(imageName: "background", waitForUpdate: false)
        SettingsBundleHelper.checkAndExecuteSettings()
        reachable = ReachabilitySetup()
        seasonalBackgroundLoader()
        if LoggedInUser.user == nil {
            LoggedInUser.setLoggedInUser()
        }

        if LoggedInUser.selectedUser == nil {
            LoggedInUser.setSelectedToLoggedIn()
        }

        if isKiosk {
            LoggedInUser.user?.isAdmin = false
            LoggedInUser.user?.isMaster = false
        }

        choreCount = UIApplication.shared.applicationIconBadgeNumber
        NotificationCenter.default.addObserver(self, selector: #selector(verifyAuthenticated), name: .isAuthenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(buildModules), name: .updateUser, object: nil)
        verifyAuthenticated()
        modules = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]
        buildModules()
        registerAPNS()
        buildAvatar()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if isKiosk && !userSelected {
            performSegue(withIdentifier: "segueSelectUser", sender: self)
        }
    }

    // MARK: resetTimer
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(segueSelectUser), userInfo: nil, repeats: false)
    }

    // MARK: buildAvatar
    func buildAvatar() {
        var gravatar = "https://www.gravatar.com/avatar/?d=mp"
        var email = ""
        avatarView.borderColor = UIColor.systemRed
        if let selectedUser = LoggedInUser.selectedUser {
            labelSwitchUser.isHidden = !LoggedInUser.user!.isAdmin
            email = selectedUser.email!
            gravatar = "https://www.gravatar.com/avatar/\(email.MD5)?d=mp"
            if selectedUser.isMaster {
                avatarView.borderColor = UIColor.systemPurple
            } else if selectedUser.isAdmin {
                avatarView.borderColor = UIColor.systemYellow
            } else if selectedUser.isChild {
                avatarView.borderColor = UIColor.systemTeal
            } else if !selectedUser.isActive {
                avatarView.borderColor = UIColor.systemRed
            }
        }
        avatarView.isHidden = false
        avatarView.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        avatarView.borderWidth = 4
        avatarView.backgroundColor = UIColor(white: 1, alpha: 0)
        avatarView.imageView.kf.setImage(
            with: URL(string: gravatar),
            placeholder: UIImage(named: "mp"),
            options: [
                .transition(.fade(1)),
                .targetCache(gravatarCache)
                ])
    }

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "UserLastUpdated") == nil || !Calendar.current.isDateInToday(UserDefaults.standard.value(forKey: "UserLastUpdated") as! Date) {
            KumpeHelpers.dispatchOnBackground {
                KumpeAppsClient.getUsers(silent: true) { (_, _) in
                    LoggedInUser.setLoggedInUser()
                    KumpeHelpers.dispatchOnMain {
                        self.buildModules()
                    }
                }
            }
        }
        if !isKiosk {
            tutorial()
        }
        if !Device.current.isSimulator {
            self.requirePrivacy()
            whatsNew.presentIfNeeded(on: self)
        }
        if isKiosk {
            resetTimer()
        }
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        reachable = nil
        iconCache.cleanExpiredCache()
        iconCache.cleanExpiredDiskCache()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        timer?.invalidate()
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

        guard !isKiosk else { return }

        guard let token = UserDefaults.standard.string(forKey: "apnsToken") else { return }

        guard token != "" else { return }

        KumpeAppsClient.registerAPNS(token)
    }

// MARK: buildModules
    @objc func buildModules() {
        if let selectedUser = LoggedInUser.selectedUser {
            modules = [KKid_Module.init(title: "Logout", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-shutdown-80.png")]

            if selectedUser.enableChores {
                modules.append(KKid_Module.init(title: "Chores", segue: "segueChores", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-to-do-80.png"))
            }

            if selectedUser.enableAllowance {
                modules.append(KKid_Module.init(title: "Allowance", segue: "segueAllowance", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-receive-cash-80.png"))
            }

            if selectedUser.enableTmdb {
                modules.append(KKid_Module.init(title: "Movies DB", segue: "segueSearchMovies", icon: UIImage(named: "tmdb")!, getRemoteIcon: false, remoteIconName: nil))
                modules.append(KKid_Module.init(title: "TV Shows DB", segue: "segueSearchShows", icon: UIImage(named: "tmdb")!, getRemoteIcon: false, remoteIconName: nil))
            }

            if selectedUser.enableWishList {
                modules.append(KKid_Module.init(title: "Wish List", segue: "segueWishList", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-wish-list-80.png"))
            }
            if !isKiosk {
                modules.append(KKid_Module.init(title: "Edit Profile", segue: "segueEditProfile", icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-profile-80.png"))

                modules.append(KKid_Module.init(title: "App Settings", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-services-50.png"))

                modules.append(KKid_Module.init(title: "User Manual", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-user_manual-50.png"))

                modules.append(KKid_Module.init(title: "Portal", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "letter_k/k_cloud.png"))

                modules.append(KKid_Module.init(title: "Support", segue: nil, icon: UIImage(named: "icons8-swirl")!, getRemoteIcon: true, remoteIconName: "icons8-strangertalk-50.png"))
            }

        }

        dispatchOnMain {
            self.collectionView.reloadData()
        }
    }

    // MARK: pressedLogout
    func pressedLogout() {
        KumpeAppsClient.logout(userInitiated: true)
    }

    // MARK: segueSelectUser
    @objc func segueSelectUser() {
        performSegue(withIdentifier: "segueSelectUser", sender: self)
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
            UserDefaults.standard.set("none", forKey: "seasonalBackgroundImage")
        }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: now)
        let currentBackground = UserDefaults.standard.string(forKey: "seasonalBackgroundImage")
        switch nameOfMonth {
        case "December":
            if currentBackground != "Christmas" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/christmas.jpg")!, isBackground: true)
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/candycane.jpg")!, isBackground: false)
                UserDefaults.standard.set("Christmas", forKey: "seasonalBackgroundImage")
            }
        case "January":
            if currentBackground != "NewYear" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/WinterNewYear.jpg")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .systemCyan)!), isBackground: false)
                UserDefaults.standard.set("NewYear", forKey: "seasonalBackgroundImage")
            }
        case "February":
            if currentBackground != "Valentines" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/valentines.jpg")!, isBackground: true)
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/valentines.jpg")!, isBackground: false)
                UserDefaults.standard.set("Valentines", forKey: "seasonalBackgroundImage")
            }
        case "March":
            if currentBackground != "StPatricks" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/clovers.jpg")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .systemGreen)!), isBackground: false)
                UserDefaults.standard.set("StPatricks", forKey: "seasonalBackgroundImage")
            }
        case "May":
            if currentBackground != "May" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/foster_care_month.jpg")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .magenta)!), isBackground: false)
                UserDefaults.standard.set("April", forKey: "seasonalBackgroundImage")
            }
        case "October":
            if currentBackground != "Halloween" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/halloween_bats.png")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .orange)!), isBackground: false)
                UserDefaults.standard.set("Halloween", forKey: "seasonalBackgroundImage")
            }
        case "November":
            if currentBackground != "Thanksgiving" {
                downloadImage(URL(string: "\(KumpeAppsClient.imageURL)/backgrounds/fall_leaves.png")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(color: .orange)!), isBackground: false)
                UserDefaults.standard.set("Thanksgiving", forKey: "seasonalBackgroundImage")
            }
        default:
                setImage(UIImage(named: "photo2")!, isBackground: true)
                setImage(Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!), isBackground: false)
                UserDefaults.standard.set("default", forKey: "seasonalBackgroundImage")
        }
        imageLogo.imageFromiCloud(imageName: "logo")
        imageBackground.imageFromiCloud(imageName: "background")
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
        switch isBackground {
        case false:
            KumpeHelpers.PersistBackgrounds.imageToiCloud(image: image, imageName: "logo", imageView: imageLogo)
        case true:
            KumpeHelpers.PersistBackgrounds.imageToiCloud(image: image, imageName: "background", imageView: imageBackground)
        }
    }

    @objc func pressedAvatar(sender: UITapGestureRecognizer) {
        KumpeHelpers.Logger.log(.action, "Pressed Avatar")
        if LoggedInUser.user!.isAdmin {
        performSegue(withIdentifier: "segueSelectUser", sender: self)
        } else {
            KumpeHelpers.ShowAlert.banner(title: "Change User Denied", message: "Only Parents/Admins can change users. You may update your avatar photo at Gravatar.com. (Link is in Edit Profile)")
        }
    }

    @IBAction func pressedAvatarButton() {
        KumpeHelpers.Logger.log(.action, "Pressed Avatar Button")
        if LoggedInUser.user!.isAdmin {
        performSegue(withIdentifier: "segueSelectUser", sender: self)
        } else {
            KumpeHelpers.ShowAlert.banner(title: "Switch User Denied", message: "Only Parents/Admins can switch users. You may update your avatar photo at Gravatar.com. (Link is in Edit Profile)")
        }
//        collectionView.delegate = self
//        collectionView.dataSource = self
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

            let disableNewIcon = ["Edit Profile","App Settings","Portal","Support","Chores","Allowance","Logout","Select User","User Manual"]

            let betaModules = ["Beta"]

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ModuleCollectionViewCell
            cell.title.text = module.title
            cell.badge.text = "0"
            cell.badge.isHidden = true
            cell.avatarView.bounds = CGRect(x: 0, y: 0, width: 63, height: 63)
            cell.avatarView.borderWidth = 0
            cell.avatarView.backgroundColor = UIColor(white: 1, alpha: 0)
            cell.avatarView.isHidden = true

            var email = ""

            if let selectedUser = LoggedInUser.selectedUser {
                email = selectedUser.email!
            }

            if module.title == "Select User" {
                var gravatar = "https://www.gravatar.com/avatar/?d=mp"
                if let selectedUser = LoggedInUser.selectedUser {
                    email = selectedUser.email!
                    gravatar = "https://www.gravatar.com/avatar/\(email.MD5)?d=mp"
                }
                cell.avatarView.isHidden = false
                    cell.avatarView.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
                    cell.avatarView.borderColor = UIColor.systemPurple
                    cell.avatarView.borderWidth = 4
                    cell.imageView.image = nil
                    cell.avatarView.backgroundColor = UIColor(white: 1, alpha: 0)
                cell.avatarView.imageView.kf.setImage(
                    with: URL(string: gravatar),
                    placeholder: UIImage(named: "mp"),
                    options: [
                        .transition(.fade(1)),
                        .targetCache(gravatarCache)
                        ])
            } else if module.getRemoteIcon && module.remoteIconName != nil {
                cell.imageView.kf.setImage(
                    with: URL(string: "\(KumpeAppsClient.imageURL)/\(module.remoteIconName!)"),
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

            if UserDefaults.standard.object(forKey: module.title) == nil && !disableNewIcon.contains(module.title) {
                cell.badge.isHidden = false
                cell.badge.text = "NEW"
            }

            if betaModules.contains(module.title) {
                cell.badge.isHidden = false
                cell.badge.text = "BETA"
            }

            return cell
        }

        // MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let module = modules[indexPath.row]
            switch module.title {
            case "Logout":
                if !isKiosk {
                    pressedLogout()
                } else {
                    performSegue(withIdentifier: "segueSelectUser", sender: self)
                }
            case "App Settings":
                let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
                UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
            case "User Manual":
                launchURL("https://github.com/kumpeapps/KKid#kkid")
            case "Portal":
                launchURL("https://khome.kumpeapps.com")
            case "Support":
                launchURL("https://github.com/kumpeapps/KKid/issues")
                Logger.log(.action, "Pressed Support")
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
