//
//  AppDelegate.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var kkidLogo = Pathifier.makeImage(for: NSAttributedString(string: "KKID"), withFont: UIFont(name: "QDBetterComicSansBold", size: 109)!, withPatternImage: UIImage(named: "money")!)
    var kkidBackground = UIImage(named: "photo2")!
    
    var loggedInUser: KKid_User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkIfFirstLaunch()
        
//        Load Logged In user from UserDefaults
        if let loggedInUser = UserDefaults.standard.object(forKey: "loggedInUser") as? Data{
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(KKid_User.self, from: loggedInUser){
                LoggedInUser.user = user
            }
        }
//        Load Data Controller
        DataController.shared.load()
        
//        Initiate DataController Autosave
        DataController.shared.autoSaveViewContext()
        
//        Get App Version and set it's value in KKid Client
        if let nsObject: AnyObject = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?{
            KKidClient.appVersion = "\(KKidClient.appVersion) \(nsObject as! String)"
        }
        
        
        return true
    }
    
    
//    MARK: applicationDidEnterBackground
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
        Logger.log(.action, "applicationDidEnterBackground")
    }
    
//    MARK: applicationWillTerminate
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

    
    //    MARK: checkIfFirstLaunch
    func checkIfFirstLaunch(){
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore"){
            Logger.log(.action, "Not First Launch")
            
            if let logo = PersistBackgrounds.loadImage(isBackground: false){
                kkidLogo = logo
                Logger.log(.success, "KKID Logo Set")
            }
            
            if let background = PersistBackgrounds.loadImage(isBackground: true){
                kkidBackground = background
                Logger.log(.success, "KKID Background Set")
            }
            
        }else{
            Logger.log(.action, "Is First Launch")
            PersistBackgrounds.saveImage(kkidLogo, isBackground: false)
            PersistBackgrounds.saveImage(kkidBackground, isBackground: true)
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            
        }
    }

}

//MARK: saveViewContext
func saveViewContext () {
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
