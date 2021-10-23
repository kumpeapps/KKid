//
//  UserEditProfileViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/22/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM
import Smile
import KumpeHelpers

class UserEditProfileViewController: FormViewController {

// MARK: Parameters
    var selectedUser = LoggedInUser.selectedUser!

// MARK: populateCurrentUserInfo
    func populateCurrentUserInfo() {
        username.value = selectedUser.username!
        email.value = selectedUser.email!
        firstName.value = selectedUser.firstName ?? ""
        lastName.value = selectedUser.lastName ?? ""
        emoji.value = selectedUser.emoji ?? "🤗"
        enableChores.value = selectedUser.enableChores
        enableAllowance.value = selectedUser.enableAllowance
        enableAdmin.value = selectedUser.isAdmin
        enableTmdb.value = selectedUser.enableTmdb
        pushChoresNew.value = selectedUser.pushChoresNew
        pushChoresReminders.value = selectedUser.pushChoresReminders
        pushAllowanceNew.value = selectedUser.pushAllowanceNew
    }

// MARK: loadView
    override func loadView() {
        super.loadView()
        installSubmitButton()
        populateCurrentUserInfo()
    }

// MARK: populate
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Edit Profile"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Edit your user profile")
        builder += username
        builder += email
        builder += firstName
        builder += lastName
        builder += emoji
        if LoggedInUser.user!.isAdmin {
            builder += SectionHeaderTitleFormItem().title("Module Access Permissions")
            builder += enableChores
            builder += enableAllowance
            builder += enableAdmin
            builder += enableTmdb
        }
        builder += SectionHeaderTitleFormItem().title("Push Notifications")
        if selectedUser.enableChores {
            builder += pushChoresNew
            builder += pushChoresReminders
        }
        if selectedUser.enableAllowance {
            builder += pushAllowanceNew
        }
        builder += SectionHeaderTitleFormItem().title("Link Accounts")
        builder += tmdbButton
    }

// MARK: username Field
    lazy var username: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Username:")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(4, 32), message: "Username must be between 4 and 32 characters")
        instance.required("Username is required")
        return instance
    }()

// MARK: email Field
    lazy var email: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Email:")
        instance.keyboardType(.emailAddress)
        instance.submitValidate(EmailSpecification(), message: "Must be an email address")
        instance.required("Email field is required")
        return instance
    }()

// MARK: firstName Field
    lazy var firstName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("First Name:")
        instance.keyboardType(.asciiCapable)
        instance.required("First Name is Required")
        return instance
    }()

// MARK: lastName Field
    lazy var lastName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Last Name:")
        instance.keyboardType(.asciiCapable)
        instance.required("Last Name is Required")
        return instance
    }()

// MARK: emoji Field
    lazy var emoji: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Emoji Icon:")
        instance.required("Emoji is required")
        return instance
    }()

// MARK: enableChores Field
    lazy var enableChores: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Chores")
        return instance
    }()

// MARK: enableAllowance Field
    lazy var enableAllowance: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Allowance")
        return instance
    }()

// MARK: enableAllowance Field
    lazy var enableTmdb: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable TMDb (Movie & TV DB)")
        return instance
    }()

// MARK: enableAdmin Field
    lazy var enableAdmin: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Admin")
        return instance
    }()

// MARK: pushChoresNew Field
    lazy var pushChoresNew: SwitchFormItem = {
        let instance = SwitchFormItem().title("New Chore Notifications")
        return instance
    }()

// MARK: pushChoresReminders Field
    lazy var pushChoresReminders: SwitchFormItem = {
        let instance = SwitchFormItem().title("Chore Reminders")
        return instance
    }()

// MARK: pushAllowanceNew Field
    lazy var pushAllowanceNew: SwitchFormItem = {
        let instance = SwitchFormItem().title("New Allowance Notifications")
        return instance
    }()

// MARK: tmdbButton
    lazy var tmdbButton: ButtonFormItem = {
        let instance = ButtonFormItem()
        instance.title = "Link TMDb Account"
        if selectedUser.tmdbKey != "" {
            instance.title = "Re-Link TMDb Account"
        }
        instance.action = { [weak self] in
            self?.authenticateTmdb()
        }
        if !selectedUser.enableTmdb {
            instance.action = {
                ShowAlert.banner(theme: .warning, title: "TMDb Not Enabled", message: "TMDb access is not enabled for this account. Please ask your parent/admin to enable TMDb on your account.")
            }
        }
        return instance
    }()

// MARK: authenticateTmdb
    func authenticateTmdb() {
        TMDb_Client.getToken { (success, token) in
            if success && token != nil {
                launchURL("https://www.themoviedb.org/authenticate/\(token!)?redirect_to=kkid-tmdb://")
            } else {
                ShowAlert.banner(title: "Error", message: "There was an error attemting to link your account.")
            }
        }
    }

// MARK: submitForm
    func submitForm() {
        guard Smile.isSingleEmoji(emoji.value) else {
            ShowAlert.banner(title: "Validation Error", message: "Emoji field must be a single emoji")
            return
        }

        KumpeAppsClient.updateUser(username: username.value, email: email.value, firstName: firstName.value, lastName: lastName.value, user: selectedUser, emoji: emoji.value, enableAllowance: enableAllowance.value, enableChores: enableChores.value, enableAdmin: enableAdmin.value, enableTmdb: enableTmdb.value, tmdbKey: nil, pushChoresNew: pushChoresNew.value, pushChoresReminders: pushChoresReminders.value, pushAllowanceNew: pushAllowanceNew.value) { (success, error) in
            if success {
                dispatchOnMain {
                    KumpeAppsClient.getUsers { (success, _) in
                        ShowAlert.statusLine(theme: .success, title: "User Updated", message: "User Updated", seconds: 3, dim: false)
                        KumpeAppsClient.getUsers(silent: true) { (_, _) in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                ShowAlert.banner(title: "Update User Error", message: error ?? "An Unknown Error Occured")
            }
        }
    }
}

// MARK: - Initiate Submit Button
extension UserEditProfileViewController {

// MARK: installSubmitButton
    public func installSubmitButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(submitAction(_:)))
    }

// MARK: submitAction
    @objc public func submitAction(_ sender: AnyObject?) {
        formBuilder.validateAndUpdateUI()
        let result = formBuilder.validate()
        showSubmitResult(result)
    }

// MARK: showSubmitResult
    public func showSubmitResult(_ result: FormBuilder.FormValidateResult) {
        switch result {
        case .valid:
            submitForm()
        case let .invalid(item, message):
            let title = item.elementIdentifier ?? "Invalid"
            form_simpleAlert(title, message)
        }
    }

}
