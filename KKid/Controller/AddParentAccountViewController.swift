//
//  AddParentAccountViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/21/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM
import KumpeHelpers

class AddParentAccountViewController: FormViewController {

// MARK: loadView
    override func loadView() {
        super.loadView()
        installSubmitButton()
    }

// MARK: populate
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Add User"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Create a new Master Parent (Home) Account")
        builder += username
        builder += email
        builder += password
        builder += firstName
        builder += lastName
        builder += footer
    }

// MARK: username Field
    lazy var username: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Username")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(4, 32), message: "Username must be between 4 and 32 characters")
        instance.required("Username is required")
        return instance
    }()

// MARK: email Field
    lazy var email: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Email")
        instance.keyboardType(.emailAddress)
        instance.submitValidate(EmailSpecification(), message: "Must be an email address")
        instance.required("Email field is required")
        return instance
    }()

// MARK: password Field
    lazy var password: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Password")
        instance.submitValidate(CountSpecification.between(7, 32), message: "Password must be between 7 and 32 characters")
        instance.validate(CountSpecification.max(32), message: "Password must be between 7 and 32 characters")
        instance.keyboardType(.asciiCapable)
        instance.password()
        instance.required("Password is required")
        return instance
    }()

// MARK: firstName Field
    lazy var firstName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("First Name")
        instance.keyboardType(.asciiCapable)
        instance.required("First Name is Required")
        return instance
    }()

// MARK: lastName Field
    lazy var lastName: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Last Name")
        instance.keyboardType(.asciiCapable)
        instance.required("Last Name is Required")
        return instance
    }()

// MARK: footer
    lazy var footer: SectionFooterViewFormItem = {
        let footerView = SectionFooterViewFormItem()
        footerView.viewBlock = {
            return InfoView(frame: CGRect(x: 0, y: 0, width: 0, height: 150), text: "Note: This is for the primary parent only. Additional parents and children are added on the users page after a parent/admin logs in.")
        }
        return footerView
    }()

// MARK: submitForm
    func submitForm() {
        KKidClient.addMaster(username: username.value, email: email.value, firstName: firstName.value, lastName: lastName.value, password: password.value) { (success, error) in
            if success {
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                    ShowAlert.statusLine(theme: .success, title: "Home Account Added", message: "Master/Home Account Added, You may now login.", seconds: 10, dim: false)
                }
            } else {
                ShowAlert.banner(title: "Error", message: error ?? "An Unknown Error Occurred")
            }
        }
    }

}

// MARK: - Initiate Submit Button
extension AddParentAccountViewController {

// MARK: installSubmitButton
    public func installSubmitButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitAction(_:)))
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
