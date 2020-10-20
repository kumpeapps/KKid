//
//  AllowanceAddTransactionViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/20/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM
import KumpeHelpers

class AllowanceAddTransactionViewController: FormViewController {

// MARK: Parameters
    var selectedUser: User?
    var transactionType = "Subtract"

// MARK: loadView
    override func loadView() {
        super.loadView()
        installSubmitButton()
    }

// MARK: populate
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Add Transaction"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Add a new transaction for \(selectedUser!.firstName ?? "Selected User")'s allowance")
        builder += transactionTypePicker
        builder += amountField
        builder += reason
    }

// MARK: transactionTypePicker
    lazy var transactionTypePicker: PickerViewFormItem = {
        let instance = PickerViewFormItem().title("Transaction Type").behavior(.collapsed)
        if LoggedInUser.user!.isAdmin {
            instance.pickerTitles = [["Subtract", "Add"]]
        } else {
            instance.pickerTitles = [["Subtract"]]
        }
        instance.valueDidChangeBlock = { [weak self] _ in
            self?.updateTransactionType()
        }
        return instance
    }()

// MARK: amountField
    lazy var amountField: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Amount  $").keyboardType(.decimalPad)
        instance.validate(CharacterSetSpecification.charactersInString("0123456789."), message: "Amount must be in decimal format!")
        instance.submitValidate(CountSpecification.min(1), message: "Amount field is Required!")
        return instance
    }()

// MARK: reason Field
    lazy var reason: TextFieldFormItem = {
        let instance = TextFieldFormItem().title("Reason")
        instance.submitValidate(CountSpecification.between(1, 100), message: "Reason must be between 1 and 100 characters!")
        instance.validate(CountSpecification.max(100), message: "Reason must not exceed 100 characters!")
        return instance
    }()

// MARK: updateTransactionType
    func updateTransactionType() {
        switch transactionTypePicker.value {
        case [1]:
            transactionType = "Add"
        default:
            transactionType = "Subtract"
        }
    }

// MARK: submitForm
    func submitForm() {
        var amount = amountField.value
        if transactionType == "Subtract" {
            amount = "-\(amountField.value)"
        }
        KKidClient.addAllowanceTransaction(userID: Int(selectedUser!.userID), amount: amount, description: reason.value, transactionType: transactionType) { (success, _) in
            if success {
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                ShowAlert.banner(title: "Error", message: "There was an error submitting this transaction. Please try again.")
            }
        }
    }
}

// MARK: - Initiate Submit Button
extension AllowanceAddTransactionViewController {

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
