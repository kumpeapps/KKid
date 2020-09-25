//
//  LoginViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/10/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import Toast_Swift

class LoginViewController: UIViewController{
    
//    MARK: Images
    @IBOutlet weak var imageLogo: UIImageView!
    
//    MARK: Fields
    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    
//    MARK: Buttons
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    @IBOutlet weak var buttonNewParentAccount: UIButton!
        
    //    MARK: Reachability
        var reachable: ReachabilitySetup!
    
    
//    MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        enableUI(true)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//        TODO: Remove Hardcoded Creds
        #if targetEnvironment(simulator)
        fieldUsername.text = "dev_KKid_Master"
        fieldPassword.text = "LetmeN2it"
        #endif
    }
    
//    MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachable = ReachabilitySetup()
    }
    
//    MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachable = nil
    }
    
    @IBAction func pressedLogin(){
        enableUI(false)
        
//        GUARD: Username and Password not blank
        guard fieldUsername.text != "" && fieldPassword.text != "" else{
            ShowAlert.banner(title: "Login Error", message: "Please enter both username and password before pressing login")
            return
        }
        
        KKidClient.authenticate(username: fieldUsername.text!, password: fieldPassword.text!){
            (response,error) in
            
//            GUARD: Login is Successful
            guard let loginStatus = response?.status, loginStatus == 1 else{
                if let errorMessage = response?.error{
                    Logger.log(.error, errorMessage)
                    self.enableUI(true)
                    ShowAlert.banner(title: "Login Error", message: errorMessage)
                }
                return
            }
            
//            GUARD: API Key exists
            guard let apiKey = response?.apiKey else{
                self.enableUI(true)
                Logger.log(.error, "API Key not returned")
                return
            }
            
//            GUARD: User Data Returned
            guard let user = response?.user else{
                self.enableUI(true)
                Logger.log(.error, "User Info not returned")
                return
            }
            
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
            LoggedInUser.user = user
            Logger.log(.authentication, "Login Successful for user \(user.username)")
             self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func submitUsername(){
        fieldPassword.becomeFirstResponder()
    }
    
    @IBAction func pressedForgotPassword(){
        enableUI(false)
        guard let username = fieldUsername.text, username != "" else{
            ShowAlert.banner(title: "Username Required", message: "Please enter the username you wish to reset the password for!")
            return
        }
        KKidClient.forgotPassword(username: username) { (success, msg) in
            if success{
                ShowAlert.banner(theme: .success, title: "Success", message: msg)
            }else{
                ShowAlert.banner(title: "Error", message: msg)
            }
            self.enableUI(true)
        }
    }
    
    //    MARK: enableUI
    func enableUI(_ enable: Bool){
        if enable{
            self.view.hideAllToasts(includeActivity: true, clearQueue: true)
        }else{
            self.view.makeToastActivity(.center)
        }
        self.fieldUsername.isEnabled = enable
        self.fieldPassword.isEnabled = enable
        self.buttonLogin.isEnabled = enable
        self.buttonForgotPassword.isEnabled = enable
        self.buttonNewParentAccount.isEnabled = enable
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
}
