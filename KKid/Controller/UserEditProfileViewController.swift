//
//  UserEditProfileViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/22/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM

class UserEditProfileViewController: FormViewController{
    
//    MARK: Parameters
    var selectedUser: User!
    
    override func loadView() {
        super.loadView()
        installSubmitButton()
        username.value = selectedUser.username!
        email.value = selectedUser.email!
        firstName.value = selectedUser.firstName ?? ""
        lastName.value = selectedUser.lastName ?? ""
        emoji.value = selectedUser.emoji ?? "🤗"
        enableChores.value = selectedUser.enableChores
        enableAllowance.value = selectedUser.enableAllowance
        enableAdmin.value = selectedUser.isAdmin
    }
    
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Edit Profile"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Edit your user profile")
        builder += username
        builder += email
        builder += firstName
        builder += lastName
        builder += emoji
        if LoggedInUser.user!.isAdmin{
            builder += enableChores
            builder += enableAllowance
            builder += enableAdmin
        }
    }
    
    lazy var username: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Username:")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(4, 32), message: "Username must be between 4 and 32 characters")
        instance.required("Username is required")
        return instance
    }()
    
    lazy var email: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Email:")
        instance.keyboardType(.emailAddress)
        instance.submitValidate(EmailSpecification(), message: "Must be an email address")
        instance.required("Email field is required")
        return instance
    }()
    
    lazy var firstName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("First Name:")
        instance.keyboardType(.asciiCapable)
        instance.required("First Name is Required")
        return instance
    }()
    
    lazy var lastName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Last Name:")
        instance.keyboardType(.asciiCapable)
        instance.required("Last Name is Required")
        return instance
    }()
    
    lazy var emoji: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Emoji Icon:")
        
        instance.required("Emoji is required")
        return instance
    }()
    
    lazy var enableChores: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Chores")
        return instance
    }()
    
    lazy var enableAllowance: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Allowance")
        return instance
    }()
    
    lazy var enableAdmin: SwitchFormItem = {
        let instance = SwitchFormItem().title("Enable Admin")
        return instance
    }()
    
    func submitForm(){
        
        KKidClient.updateUser(username: username.value, email: email.value, firstName: firstName.value, lastName: lastName.value, user: selectedUser, emoji: emoji.value, enableAllowance: enableAllowance.value, enableChores: enableChores.value, enableAdmin: enableAdmin.value) { (success, error) in
            if success{
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                    KKidClient.getUsers { (success, error) in
                        ShowAlert.statusLine(theme: .success, title: "User Updated", message: "User Updated", seconds: 3, dim: false)
                    }
                }
            }else{
                ShowAlert.banner(title: "Update User Error", message: error ?? "An Unknown Error Occured")
            }
        }
    }
}

extension UserEditProfileViewController{
    
    public func installSubmitButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(submitAction(_:)))
    }
    
    @objc public func submitAction(_ sender: AnyObject?) {
        formBuilder.validateAndUpdateUI()
        let result = formBuilder.validate()
        showSubmitResult(result)
    }
    
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
