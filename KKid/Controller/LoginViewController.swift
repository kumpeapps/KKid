//
//  LoginViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/10/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import KumpeHelpers
import PrivacyKit
import TransitionButton
import YubiKit
import DeviceKit
import BLTNBoard

class LoginViewController: UIViewController, PrivacyKitDelegate {

// MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!

// MARK: Fields
    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    var otp: String?

// MARK: Buttons
    @IBOutlet weak var buttonLogin: TransitionButton!
    @IBOutlet weak var buttonForgotPassword: TransitionButton!
    @IBOutlet weak var buttonNewParentAccount: TransitionButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    var bulletinManager: BLTNItemManager?

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
        self.navigationItem.setHidesBackButton(true, animated: true)
        #if targetEnvironment(simulator)
        fieldUsername.text = "dev_kkid_master"
        fieldPassword.text = "LetmeN2it"
        #endif
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
        buttonLogin.startAnimation()
//        GUARD: Username and Password not blank
        guard fieldUsername.text != "" && fieldPassword.text != "" else {
            ShowAlert.banner(title: "Login Error", message: "Please enter both username and password before pressing login")
            enableUI(true)
            buttonLogin.stopAnimation()
            return
        }

        KumpeAppsClient.authenticate(username: fieldUsername.text!, password: fieldPassword.text!, otp: self.otp) { (response, error, statusCodeResponse) in

            guard statusCodeResponse.statusCode != 449 else {
                Logger.log(.authentication, statusCodeResponse.statusDescription)
                self.verifyOtp()
                return
            }

            guard statusCodeResponse.statusCategory == .Success else {
                let errorMessage = statusCodeResponse.statusDescription
                Logger.log(.error, errorMessage)
                self.buttonLogin.stopAnimation()
                self.enableUI(true)
                ShowAlert.banner(title: "Login Error", message: errorMessage)
                return
            }

//            GUARD: Login is Successful
            guard let loginStatus = response?.status, loginStatus == 1 else {
                self.otp = nil
                if let errorMessage = response?.error {
                    Logger.log(.error, errorMessage)
                    self.buttonLogin.stopAnimation()
                    self.enableUI(true)
                    ShowAlert.banner(title: "Login Error", message: errorMessage)
                }
                return
            }

//            GUARD: API Key exists
            guard let apiKey = response?.apiKey else {
                self.buttonLogin.stopAnimation()
                self.enableUI(true)
                Logger.log(.error, "API Key not returned")
                return
            }

//            GUARD: User Data Returned
            guard let user = response?.user else {
                self.buttonLogin.stopAnimation()
                self.enableUI(true)
                Logger.log(.error, "User Info not returned")
                return
            }

            self.checkKiosk(apiKey: apiKey, user: user)

        }
    }

    // MARK: checkKiosk
    func checkKiosk(apiKey: String, user: KKid_User) {
        if self.fieldUsername.text!.contains("kiosk:") {
            guard user.isAdmin! else {
                ShowAlert.centerView(theme: .error, title: "Not Admin", message: "You must be a Parent/Admin to enable kiosk mode!")
                self.buttonLogin.stopAnimation()
                self.enableUI(true)
                KumpeAppsClient.apiLogout(apiKey)
                return
            }
            let bulletinManager: BLTNItemManager = {
                let page = BLTNPageItem(title: "Kiosk Mode")
                page.image = UIImage(named: "kiosk")

                page.descriptionText = "It appears you wish to enable Kiosk Mode for this device. All admin functions will be disabled and Logout will take you to the select user screen instead of logging out. Do you wish to proceed?"
                page.actionButtonTitle = "Enable Kiosk Mode"
                page.alternativeButtonTitle = "Not now"
                page.actionHandler = { _ in
                    Logger.log(.action, "Set Kiosk Mode")
                    UserDefaults.standard.set(true, forKey: "enableKiosk")
                    Logger.log(.action, "Enable Kiosk: \(UserDefaults.standard.bool(forKey: "enableKiosk"))")
                    self.setLoggedInUser(apiKey: apiKey, user: user)
                    self.dismiss(animated: false)
                }
                page.isDismissable = false
                page.alternativeHandler = { (_) in
                    Logger.log(.action, "Skipped Set Kiosk Mode")
                    UserDefaults.standard.set(false, forKey: "enableKiosk")
                    self.setLoggedInUser(apiKey: apiKey, user: user)
                    self.dismiss(animated: false)
                }
                    return BLTNItemManager(rootItem: page)
                }()
            self.bulletinManager = bulletinManager
            self.bulletinManager!.showBulletin(above: self, animated: true)
        } else {
            UserDefaults.standard.set(false, forKey: "enableKiosk")
            self.setLoggedInUser(apiKey: apiKey, user: user)
        }
    }

    // MARK: setLoggedInUser
    func setLoggedInUser(apiKey: String, user: KKid_User) {
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(user.userID, forKey: "loggedInUserID")
        KumpeAppsClient.getUsers(silent: true) { (success, error) in
            if success {
                Logger.log(.authentication, "Login Successful for user \(user.username ?? "")")
                LoggedInUser.setLoggedInUser()
                // self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                self.buttonLogin.stopAnimation()
                self.enableUI(true)
                ShowAlert.banner(title: "Sync Error", message: error ?? "An Unknown Error Occurred")
            }
        }
    }

    // MARK: verifyOtp
    func verifyOtp() {
        buttonLogin.startAnimation()
        // create the actual alert controller view that will be the pop-up
        let alertController = UIAlertController(title: "YubiKey Required", message: "Enter your YubiKey OTP", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            // configure the properties of the text field
            textField.placeholder = "OTP"
        }

        if YubiKitDeviceCapabilities.supportsNFCScanning {
            // add the buttons/actions to the view controller
            let cancelAction = UIAlertAction(title: "NFC", style: .cancel) { _ in
                self.otp = ""
                YubiKitManager.shared.otpSession.requestOTPToken { token, _ in
                    guard let token = token else {
                        self.pressedLogin()
                        return
                    }
                    self.otp = token.value
                    self.pressedLogin()
                    }
            }
            alertController.addAction(cancelAction)
        }
        let saveAction = UIAlertAction(title: "Login", style: .default) { _ in
            let inputName = alertController.textFields![0].text
            self.otp = inputName
            self.pressedLogin()
        }

        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
        self.buttonLogin.stopAnimation()
        self.enableUI(true)
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
        KumpeAppsClient.forgotPassword(username: username) { (success, msg) in
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
        // Move Screen Up only if editing bottom text field
        if (fieldUsername.isEditing || fieldPassword.isEditing) && UIDevice.current.orientation.isLandscape && !Device.current.isPad {
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
        if let disableNewParent = ManagedAppConfig.shared.getConfigValue(forKey: "disableNewParentAccount") as? Bool {
            buttonNewParentAccount.isEnabled = !disableNewParent
            buttonNewParentAccount.isHidden = disableNewParent
            buttonNewParentAccount.alpha = 0.5
        }

        if let disableResetPassword = ManagedAppConfig.shared.getConfigValue(forKey: "disableResetPassword") as? Bool {
            buttonForgotPassword.isEnabled = !disableResetPassword
            buttonForgotPassword.isHidden = disableResetPassword
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
