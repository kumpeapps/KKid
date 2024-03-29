//
//  SceneDelegate.swift
//  KKid
//
//  Created by Justin Kumpe on 8/28/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        saveViewContext()
        Logger.log(.action, "applicationDidEnterBackground")
        submitBackgroundTasks()
    }

    func submitBackgroundTasks() {
        Logger.log(.action, "submitBackgroundTasks")

        do {
            let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: "com.kumpeapps.ios.KKid.background.refresh")
            backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow:  5 * 60)
            try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
            Logger.log(.action, "Submitted task request")
        } catch {
            Logger.log(.error, "Failed to submit BGTask")
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if url.scheme == "kkid-tmdb" {
                let parameters = url.parameters ?? [:]
                let token = parameters["request_token"] ?? ""
                let approved = parameters["approved"] ?? ""
                guard approved == "true" else {
                    return
                }
                TMDb_Client.getSession(requestToken: token)
            }
        }
    }

}
