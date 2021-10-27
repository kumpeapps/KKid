//
//  AddUserViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/21/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM
import KumpeHelpers

class AddWishViewController: FormViewController {
    
// MARK: parameters
    let user = LoggedInUser.selectedUser

// MARK: loadView
    override func loadView() {
        super.loadView()
        installSubmitButton()
    }

// MARK: populate
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Add Wish"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Add an item to your wish list.")
        builder += wishTitle
        builder += wishDescription
        builder += link
        builder += footer
    }

// MARK: title Field
    lazy var wishTitle: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Title")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(1, 45), message: "Title must be between 1 and 45 characters")
        instance.required("Title is required")
        return instance
    }()

// MARK: description Field
    lazy var wishDescription: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Description")
        instance.keyboardType(.asciiCapable)
        instance.submitValidate(CountSpecification.between(0, 100), message: "Title is limited to a max of 100 characters")
        return instance
    }()

// MARK: link Field
    lazy var link: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("URL Link to item")
        instance.keyboardType(.URL)
        return instance
    }()

// MARK: submitForm Field
    func submitForm() {
        KumpeAppsClient.addWish(userID: "\(user!.userID)", title: wishTitle.value, description: wishDescription.value, priority: 5, link: link.value) { success, error in
            if success {
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                    ShowAlert.statusLine(theme: .success, title: "Wish Added", message: "Wish Added", seconds: 5, dim: false)
                    KumpeAppsClient.getWishes(silent: false) { (_, _) in}
                }
            } else {
                ShowAlert.banner(title: "Error", message: error!)
            }
        }
    }

// MARK: footer
    lazy var footer: SectionFooterViewFormItem = {
        let footerView = SectionFooterViewFormItem()
        footerView.viewBlock = {
            return InfoView(frame: CGRect(x: 0, y: 0, width: 0, height: 150), text: "HINT: URL link is not required but may help your parent find the exact item you want instead of having to guess they got the correct thing or not getting it at all becuase they just do not know what it is you are asking for.")
        }
        return footerView
    }()
}

// MARK: - Initiate Submit Button
extension AddWishViewController {

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
