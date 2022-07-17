//
//  TutorialManager.swift
//  KKid
//
//  Created by Justin Kumpe on 7/17/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import PBTutorialManager
import KumpeHelpers
import DeviceKit

let appBuildString: String? = (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
let appBuild = Int(appBuildString!)

extension HomeViewController {

    func homeTutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildHome")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildHome")

        // target avatar photo
        let targetAvatar = TutorialTarget(view: avatarView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.left)
            .shape(.roundedRect)
            .message("Avatar Photo")
            .breakPoint(true)
        let targetUsers = TutorialTarget(view: avatarView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.roundedRect)
            .message("Add/Delete/Manage Users")
            .breakPoint(true)

        // target select module
        let targetModules = TutorialTarget(view: collectionView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .labelWidth(200)
            .position(.top)
            .shape(.roundedRect)
            .message("To launch a module just tap on it's icon.")
            .breakPoint(true)
        let targetModules2 = TutorialTarget(view: collectionView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .labelWidth(200)
            .position(.top)
            .shape(.roundedRect)
            .message("Modules that have not yet been launched on this device will have the NEW badge.")
            .breakPoint(true)
        let targetModules3 = TutorialTarget(view: collectionView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .labelWidth(200)
            .position(.top)
            .shape(.roundedRect)
            .message("Select Edit Profile to change user permissions and turn notifications on/off.")
            .breakPoint(true)

        // add targets changed since build 31
        if lastBuild < 31 {
            tutorialManager.addTarget(targetAvatar)
            if LoggedInUser.user!.isAdmin {
                tutorialManager.addTarget(targetUsers)
            }
            tutorialManager.addTargets([targetModules,targetModules2,targetModules3])
        }

        // Start Tutorial
        tutorialManager.fireTargets()
    }
}

extension ChoresViewController {

    func choresTutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildHome")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildHome")

        // target add button
        let targetAdd = TutorialTarget(view: buttonAdd.view)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.elipse)
            .message("Add New Chores")

        // target chores table
        let targetTable = TutorialTarget(view: tableView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .labelWidth(200)
            .position(.top)
            .shape(.roundedRect)
            .message("Chores are listed in the table below in order of Priority")
            .breakPoint(true)
        let targetTable2 = TutorialTarget(view: tableView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .labelWidth(200)
            .position(.top)
            .shape(.roundedRect)
            .message("Tap on a chore to change the status of the chore (like checking it off as completed)")
            .breakPoint(true)

        // add targets changed since build 31
        if lastBuild < 31 {
            if LoggedInUser.user!.isAdmin {
                tutorialManager.addTargets([targetAdd])
            }
            tutorialManager.addTargets([targetTable,targetTable2])
        }

        // Start Tutorial
        tutorialManager.fireTargets()
    }

}

extension UIBarButtonItem {

    var view: UIView? {
        guard let view = self.value(forKey: "view") as? UIView else {
            return nil
        }
        return view
    }

}
