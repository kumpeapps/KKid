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
import UnsplashPhotoPicker
import Kingfisher

class UserEditProfileViewController: FormViewController {

// MARK: Parameters
    var selectedUser = LoggedInUser.selectedUser!

    // MARK: Unsplash Params
    let unsplashConfig = UnsplashPhotoPickerConfiguration(accessKey: APICredentials.Unsplash.access,
                                                          secretKey: APICredentials.Unsplash.secret,
                                                          allowsMultipleSelection: false,
                                                          contentFilterLevel: .high)

// MARK: populateCurrentUserInfo
    func populateCurrentUserInfo() {
        username.value = selectedUser.username!
        email.value = selectedUser.email!
        firstName.value = selectedUser.firstName ?? ""
        lastName.value = selectedUser.lastName ?? ""
        enableWishList.value = selectedUser.enableWishList
        enableChores.value = selectedUser.enableChores
        enableAllowance.value = selectedUser.enableAllowance
        enableAdmin.value = selectedUser.isAdmin
        enableTmdb.value = selectedUser.enableTmdb
        pushChoresNew.value = selectedUser.pushChoresNew
        pushChoresReminders.value = selectedUser.pushChoresReminders
        pushAllowanceNew.value = selectedUser.pushAllowanceNew
    }

    // MARK: viewWillAppear
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            switch self.traitCollection.userInterfaceStyle {
            case .light: navigationController?.navigationBar.tintColor = UIColor.black
            default: navigationController?.navigationBar.tintColor = UIColor.white
            }
        }

    // MARK: viewWillDisappear
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.navigationBar.tintColor = UIColor.white
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
        if LoggedInUser.user!.isAdmin {
            builder += SectionHeaderTitleFormItem().title("Module Access Permissions")
            builder += enableWishList
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
        builder += SectionHeaderTitleFormItem().title("Link Accounts/Customization")
        builder += gravatarButton
        builder += tmdbButton
        if selectedUser == LoggedInUser.user {
            builder += updateBackgroundButton
        }
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

// MARK: enableWishList Field
    lazy var enableWishList: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Wish List")
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

    // MARK: gravatarButton
        lazy var gravatarButton: ButtonFormItem = {
            let instance = ButtonFormItem()
            instance.title = "Update Avatar/Profile Picture"
            instance.action = { [weak self] in
                self?.updateGravatar()
            }
            return instance
        }()

    // MARK: updateBackgroundButton
        lazy var updateBackgroundButton: ButtonFormItem = {
            let instance = ButtonFormItem()
            instance.title = "Set Custom Background"
            instance.action = { [weak self] in
                self?.setCustomBackground()
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

// MARK: updateGravatar
    func updateGravatar() {
        launchURL("https://www.gravatar.com")
    }

    // MARK: setCustomBackground
    func setCustomBackground() {
        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: unsplashConfig)
        unsplashPhotoPicker.photoPickerDelegate = self
        present(unsplashPhotoPicker, animated: true, completion: nil)
    }

// MARK: submitForm
    func submitForm() {

        KumpeAppsClient.updateUser(username: username.value, email: email.value, firstName: firstName.value, lastName: lastName.value, user: selectedUser, emoji: selectedUser.email ?? "🤗", enableAllowance: enableAllowance.value, enableWishList: enableWishList.value, enableChores: enableChores.value, enableAdmin: enableAdmin.value, enableTmdb: enableTmdb.value, tmdbKey: nil, pushChoresNew: pushChoresNew.value, pushChoresReminders: pushChoresReminders.value, pushAllowanceNew: pushAllowanceNew.value) { (success, error) in
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

// MARK: - UnsplashPhotoPickerDelegate
extension UserEditProfileViewController: UnsplashPhotoPickerDelegate {
    func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
        print("Unsplash photo picker did select \(photos.count) photo(s)")
        let photo = photos[0]
        let photoUrl = photo.urls[.regular]
        let artist = photo.user
        let utmLink = "https://unsplash.com/@\(artist.username)?utm_source=kkid&utm_medium=referral"
        Logger.log(.codeWarning, artist)

        let downloader = ImageDownloader.default
        ShowAlert.displayMessage(layout: .centeredView, showButton: true, buttonTitle: "View \(artist.name ?? "Artist")'s Profile", theme: .success, alertMessage: ShowAlert.AlertMessage.init(title: "Custom Background Set", message: "Your selected image by \(artist.name ?? "Unknown Artist") on Unsplash has been set as your background image. Consider viewing the Artist's profile on Unsplash."), presentationStyle: .center, duration: .seconds(seconds: 15), interfaceMode: .blur, invokeHaptics: true) { viewArtist in
            if viewArtist {
                KumpeHelpers.launchURL(utmLink)
            }
        }
        downloader.downloadImage(with: photoUrl!, completionHandler: { result in
            switch result {
            case .success(let value):
                let image = value.image
                KumpeHelpers.PersistBackgrounds.imageToiCloud(image: image, imageName: "custom_background", imageView: HomeViewController().imageBackground)
            case .failure(let error):
                Logger.log(.error, error)
            }
        })
    }

    func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        print("Unsplash photo picker did cancel")
    }

}
