//
//  SettingsBundleHelper.swift
//
//  Created by Abhilash on 28/03/17.
//
import Foundation
import CoreData
import UIKit
import KumpeHelpers
import PrivacyKit
import Kingfisher

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let Reset = "RESET_APP_KEY"
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.Reset) {
            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.Reset)
            let appDomain: String? = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            UIApplication.shared.applicationIconBadgeNumber = 0
            self.clearAllCoreData()
            UserDefaults.standard.reset()
            PrivacyKit.shared.resetState()
            NotificationCenter.default.post(name: .isAuthenticated, object: nil)
            let iconCache = ImageCache(name: "iconCache")
            iconCache.clearCache()
            let movieCache = ImageCache(name: "movieCache")
            movieCache.clearCache()
        }
    }

    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }

    class public func clearAllCoreData() {
        let entities = DataController.shared.persistentContainer.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(clearDeepObjectEntity)
    }

    class public func clearDeepObjectEntity(_ entity: String) {
        let context = DataController.shared.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("There was an error")
        }
    }
}

extension UserDefaults {

    enum Keys: String, CaseIterable {

        case unitsNotation
        case temperatureNotation
        case allowDownloadsOverCellular

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
