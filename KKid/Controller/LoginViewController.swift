//
//  LoginViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/10/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import Toast_Swift
import KumpeHelpers
import PrivacyKit

class LoginViewController: UIViewController, PrivacyKitDelegate {

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!

// MARK: Fields
    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!

// MARK: Buttons
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    @IBOutlet weak var buttonNewParentAccount: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!

// MARK: Reachability
    var reachable: ReachabilitySetup!

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        enableUI(true)
        setupStackView()
        hideKeyboardOnTap()
    }

// MARK: setupStackView
    fileprivate func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 30).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60).isActive = true
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
        subscribeToKeyboardNotifications()
        managedConfig()
    }

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requirePrivacy()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachable = nil
        unsubscribeFromKeyboardNotifications()
    }

// MARK: pressedLogin
    @IBAction func pressedLogin() {
        enableUI(false)

//        GUARD: Username and Password not blank
        guard fieldUsername.text != "" && fieldPassword.text != "" else {
            ShowAlert.banner(title: "Login Error", message: "Please enter both username and password before pressing login")
            enableUI(true)
            return
        }

        KKidClient.authenticate(username: fieldUsername.text!, password: fieldPassword.text!) { (response, error) in

//            GUARD: Login is Successful
            guard let loginStatus = response?.status, loginStatus == 1 else {
                if let errorMessage = response?.error {
                    Logger.log(.error, errorMessage)
                    self.enableUI(true)
                    ShowAlert.banner(title: "Login Error", message: errorMessage)
                }
                return
            }

//            GUARD: API Key exists
            guard let apiKey = response?.apiKey else {
                self.enableUI(true)
                Logger.log(.error, "API Key not returned")
                return
            }

//            GUARD: User Data Returned
            guard let user = response?.user else {
                self.enableUI(true)
                Logger.log(.error, "User Info not returned")
                return
            }

            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
            UserDefaults.standard.set(user.userID, forKey: "loggedInUserID")
            KKidClient.getUsers(silent: true) { (success, error) in
                if success {
                    Logger.log(.authentication, "Login Successful for user \(user.username)")
                    LoggedInUser.setLoggedInUser()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.enableUI(true)
                    ShowAlert.banner(title: "Sync Error", message: error ?? "An Unknown Error Occurred")
                }
            }

        }
    }

// MARK: submitUsername
    @IBAction func submitUsername() {
        fieldPassword.becomeFirstResponder()
    }

// MARK: pressedForgotPassword
    @IBAction func pressedForgotPassword() {
        enableUI(false)
        guard let username = fieldUsername.text, username != "" else {
            ShowAlert.banner(title: "Username Required", message: "Please enter the username you wish to reset the password for!")
            enableUI(true)
            return
        }
        KKidClient.forgotPassword(username: username) { (success, msg) in
            if success {
                ShowAlert.banner(theme: .success, title: "Success", message: msg)
            } else {
                ShowAlert.banner(title: "Error", message: msg)
            }
            self.enableUI(true)
        }
    }

    // MARK: enableUI
    func enableUI(_ enable: Bool) {
        if enable {
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        } else {
            self.view.makeToastActivity(.center)
        }
        self.fieldUsername.isEnabled = enable
        self.fieldPassword.isEnabled = enable
        self.buttonLogin.isEnabled = enable
        self.buttonForgotPassword.isEnabled = enable
        self.buttonNewParentAccount.isEnabled = enable
    }

    // MARK: Subscribe to Keyboard Notifications
    //    Nofifies when keyboard appears/disappears
        func subscribeToKeyboardNotifications() {

            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

    // MARK: Unsubscribe from Keyboard Notifications
        func unsubscribeFromKeyboardNotifications() {

            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }

    // MARK: Keyboard Will Show
    //    Gets called when keyboard is coming onto the screen
        @objc func keyboardWillShow(_ notification: Notification) {
    //        Move Screen Up only if editing bottom text field
            if (fieldUsername.isEditing || fieldPassword.isEditing) && UIDevice.current.orientation.isLandscape {
                view.frame.origin.y = 0
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }

    // MARK: Keyboard Will Hide
    //    Gets called when keyboard is disappearing from the screen
        @objc func keyboardWillHide(_ notification: Notification) {

            view.frame.origin.y = 0
        }

    // MARK: Get Keyboard Height
        func getKeyboardHeight(_ notification: Notification) -> CGFloat {

            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
            return keyboardSize.cgRectValue.height
        }

// MARK: hideKeyboardOnTap
    func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

// MARK: managedConfig
    func managedConfig() {
        if let disableNewParent = ManagedAppConfig.shared.getConfigValue(forKey: "disableNewParent") as? Bool {
            buttonNewParentAccount.isEnabled = !disableNewParent
            buttonNewParentAccount.alpha = 0.5
        }

        if let disableResetPassword = ManagedAppConfig.shared.getConfigValue(forKey: "disableResetPassword") as? Bool {
            buttonForgotPassword.isEnabled = !disableResetPassword
            buttonForgotPassword.alpha = 0.5
        }

        if let username = ManagedAppConfig.shared.getConfigValue(forKey: "username") as? String {
            fieldUsername.text = username
        }

        if let lockUsername = ManagedAppConfig.shared.getConfigValue(forKey: "lockUsername") as? Bool {
            fieldUsername.isEnabled = !lockUsername
            if lockUsername {
                fieldUsername.alpha = 0.5
            }
        }

        if let password = ManagedAppConfig.shared.getConfigValue(forKey: "password") as? String {
            fieldPassword.text = password
        }
    }
}
