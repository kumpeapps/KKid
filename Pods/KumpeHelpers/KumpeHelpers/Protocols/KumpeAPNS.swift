//
//  KumpeAPNS.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 10/16/20.
//

import Foundation
import UIKit
import UserNotifications

public protocol KumpeAPNS: UNUserNotificationCenterDelegate {
    func registerForPushNotifications()
    func getNotificationSettings()
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    )
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    )
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    )
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data
    )
    func didFailToRegisterForRemoteNotificationsWithError(error: Error
    )
}

public extension KumpeAPNS {
        
    //    MARK: registerForPushNotifications
        func registerForPushNotifications() {
            UNUserNotificationCenter.current()
              .requestAuthorization(
                options: [.alert, .sound, .badge, .announcement]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
              }

            
        }


    //    MARK: getNotificationSettings
        func getNotificationSettings() {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
            }

          }
        }

    //    MARK: application: didRegisterForRemoteNotificationsWithDeviceToken
        func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data
        ) {
          let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
          let token = tokenParts.joined()
          print("Device Token: \(token)")
            UserDefaults.standard.set(token, forKey: "apnsToken")
        }

    //    MARK: application: didFailToRegisterForRemoteNotificationsWithError
        func didFailToRegisterForRemoteNotificationsWithError(error: Error
        ) {
          print("Failed to register: \(error)")
        }
        
}
