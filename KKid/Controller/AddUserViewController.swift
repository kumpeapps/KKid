//
//  AddUserViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/21/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM

class AddUserViewController: FormViewController{
    
    
    override func loadView() {
        super.loadView()
        installSubmitButton()
    }
    
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Add User"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Add a new user under your master account. NOTE: each user must have their own unique email address.")
        builder += username
        builder += email
        builder += password
        builder += firstName
        builder += lastName
        builder += footer
    }

    
    lazy var username: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Username")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(4, 32), message: "Username must be between 4 and 32 characters")
        instance.required("Username is required")
        return instance
    }()
    
    lazy var email: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Email")
        instance.keyboardType(.emailAddress)
        instance.submitValidate(EmailSpecification(), message: "Must be an email address")
        instance.required("Email field is required")
        return instance
    }()
    
    lazy var password: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Password")
        instance.submitValidate(CountSpecification.between(7, 32), message: "Password must be between 7 and 32 characters")
        instance.validate(CountSpecification.max(32), message: "Password must be between 7 and 32 characters")
        instance.keyboardType(.asciiCapable)
        instance.password()
        instance.required("Password is required")
        return instance
    }()
    
    lazy var firstName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("First Name")
        instance.keyboardType(.asciiCapable)
        instance.required("First Name is Required")
        return instance
    }()
    
    lazy var lastName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Last Name")
        instance.keyboardType(.asciiCapable)
        instance.required("Last Name is Required")
        return instance
    }()
    
    func submitForm(){
        KKidClient.addUser(username: username.value, email: email.value, firstName: firstName.value, lastName: lastName.value, password: password.value) { (success, error) in
            if success{
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                    ShowAlert.statusLine(theme: .success, title: "User Added", message: "User Added", seconds: 5, dim: false)
                    KKidClient.getUsers(silent: false) { (success, error) in}
                }
            }else{
                ShowAlert.banner(title: "Error", message: error!)
            }
        }
    }
    
    lazy var footer: SectionFooterViewFormItem = {
        let footerView = SectionFooterViewFormItem()
        footerView.viewBlock = {
            return InfoView(frame: CGRect(x: 0, y: 0, width: 0, height: 150), text: "HINT: Email addresses have a build in alias feature by putting +alias in front of the @ symbol. Example: If your email is jane@doe.com and you need an email address for jack you can use jane+jack@doe.com and emails will automatically be forwarded to jane@doe.com.")
        }
        return footerView
    }()
}

extension AddUserViewController{
    
    public func installSubmitButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitAction(_:)))
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
