//
//  TutorialManager.swift
//  KKid
//
//  Created by Justin Kumpe on 7/17/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import PBTutorialManager
import KumpeHelpers
import UIKit

let appBuildString: String? = (Bundle.main.infoDictionary!["CFBundleVersion"] as! String)
let appBuild = Int(appBuildString!)

extension HomeViewController {

    func tutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildHome")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildHome")

        // target avatar photo
        let targetAvatar = createTutorialTarget(view: avatarView, message: "Avatar Photo", position: .left)
        let targetUsers = createTutorialTarget(view: avatarView, message: "Add/Delete/Manage Users", position: .bottom)

        // target select module
        let targetModules = createTutorialTarget(view: collectionView, message: "To launch a module just tap on it's icon.", position: .top)
        let targetModules2 = createTutorialTarget(view: collectionView, message: "Modules that have not yet been launched on this device will have the NEW badge.", position: .top)
        let targetModules3 = createTutorialTarget(view: collectionView, message: "Select Edit Profile to change user permissions and turn notifications on/off.", position: .top)

        // add targets changed since build 32
        if lastBuild < 32 {
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

    func tutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildChores")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildChores")

        // target add button
        let targetAdd = createTutorialTarget(view: buttonAdd.view, message: "Add New Chores", position: .left, shape: .elipse, breakPoint: false)

        // target chores table
        let targetTable = createTutorialTarget(view: tableView, message: "Chores are listed in the table below in order of Priority", position: .top)
        let targetTable2 = createTutorialTarget(view: tableView, message: "Tap on a chore to change the status of the chore (like checking it off as completed)", position: .top)

        // add targets changed since build 32
        if lastBuild < 32 {
            if LoggedInUser.user!.isAdmin {
                tutorialManager.addTargets([targetAdd])
            }
            tutorialManager.addTargets([targetTable,targetTable2])
        }

        // Start Tutorial
        tutorialManager.fireTargets()
    }

}

extension MarkChoreViewController {

    func tutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildMarkChore")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildMarkChore")

        // Create Targets
        let targetCheck = createTutorialTarget(view: buttonCheck, message: "Mark Chore as Complete", position: .bottom, breakPoint: false)
        let targetDash = createTutorialTarget(view: buttonDash, message: "Mark Chore as Not Needed", position: .bottom, breakPoint: false)
        let targetX = createTutorialTarget(view: buttonX, message: "Mark Chore as Will Not Complete", position: .bottom)

        // Add targets since build 32
        if lastBuild < 32 {
            tutorialManager.addTargets([targetCheck,targetDash,targetX])
        }

        // Start Tutorial
        tutorialManager.fireTargets()

    }

}

extension AllowanceViewController {

    func tutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildAllowance")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildAllowance")

        // Create Targets
        let targetAdd = createTutorialTarget(view: buttonAdd.view, message: "Add/Subtract Allowance", position: .left, shape: .elipse, breakPoint: false)
        let targetAmount = createTutorialTarget(view: imageBalance, message: "Current Balance", position: .top)
        let targetLedger = createTutorialTarget(view: buttonLedger.view, message: "View Allowance Ledger", position: .bottom, shape: .elipse)

        // Add targets since build 32
        if lastBuild < 32 {
            tutorialManager.addTargets([targetAdd,targetAmount,targetLedger])
        }

        // Start Tutorial
        tutorialManager.fireTargets()
    }

}

extension WishListViewController {
    func tutorial() {
        let tutorialManager = TutorialManager(parent: view.window!)
        let lastBuild = UserDefaults.standard.integer(forKey: "lastBuildWishList")
        UserDefaults.standard.set(appBuild, forKey: "lastBuildWishList")

        // Create Targets
        let targetAdd = createTutorialTarget(view: buttonAdd.view, message: "Add Wish to List", position: .bottom, shape: .elipse, breakPoint: false)
        let targetShare = createTutorialTarget(view: buttonShare.view, message: "Share list wth Family/Friends", position: .left, shape: .elipse, breakPoint: false)
        let targetList = createTutorialTarget(view: tableView, message: "Wish List", position: .top)

        // Add targets since build 33
        if lastBuild < 33 {
            tutorialManager.addTargets([targetAdd,targetShare,targetList])
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

public func createTutorialTarget(view: UIView?, message: String, position: TutorialTarget.TargetPosition, shape: HoleShape = .roundedRect, breakPoint: Bool = true) -> TutorialTarget {
    let target = TutorialTarget(view: view)
        .withArrow(true)
        .widthArrow(50)
        .heightArrow(50)
        .labelWidth(200)
        .position(position)
        .shape(shape)
        .message(message)
        .breakPoint(breakPoint)
    return target
}
