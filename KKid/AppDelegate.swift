//
//  AppDelegate.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import PrivacyKit
import KumpeHelpers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KumpeAPNS {

    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.badge,.sound])
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        didFailToRegisterForRemoteNotificationsWithError(error: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }

    var window: UIWindow?

    var kkidLogo = Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!)
    var kkidBackground = UIImage(named: "photo2")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        Setup PrivacyKit
        PrivacyKit.shared.setStyle(CustomPrivacyKitStyle())
        PrivacyKit.shared.setBlurView(isEnabled: true)
        PrivacyKit.shared.config("https://tos.kumpeapps.com")
        PrivacyKit.shared.disableDeny()
        PrivacyKit.shared.setTitle("Terms of Service & Privacy Policy")
        PrivacyKit.shared.setMessage("By utilizing this app you agree and consent to our Privacy Policy and Terms of Service as listed at https://tos.kumpeapps.com.", privacyPolicyLinkText: "https://tos.kumpeapps.com", termsLinkText: "Terms of Service")

//        Configure Google AdMob
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
            [ "a29d3456cf840382ad3824c1e1115b74", "\(kGADSimulatorID)" ]
        GADMobileAds.sharedInstance().requestConfiguration.tag(forChildDirectedTreatment: true)
        GADMobileAds.sharedInstance().start(completionHandler: nil)

//        Load Data Controller
        DataController.shared.load()

//        Initiate DataController Autosave
        DataController.shared.autoSaveViewContext()
//        Get App Version and set it's value in KKid Client
        if let nsObject: AnyObject = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject? {
            KKidClient.appVersion = "\(KKidClient.appVersion) \(nsObject as! String)"
        }

        if UserDefaults.standard.string(forKey: "loggedInUserID") == nil {
            UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        }

        #if !targetEnvironment(simulator)
            registerForPushNotifications()
        #endif

        SettingsBundleHelper.checkAndExecuteSettings()
        SettingsBundleHelper.setVersionAndBuildNumber()

        return true
    }

// MARK: applicationDidEnterBackground
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
        Logger.log(.action, "applicationDidEnterBackground")
    }

// MARK: applicationWillTerminate
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SettingsBundleHelper.checkAndExecuteSettings()
        SettingsBundleHelper.setVersionAndBuildNumber()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.log(.action, "applicationWillEnterForeground")
    }

}

// MARK: saveViewContext
func saveViewContext() {
    let context = DataController.shared.viewContext
    if context.hasChanges {
        do {
            try context.save()
            Logger.log(.action, "Autosaving")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

}
