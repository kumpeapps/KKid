//
//  AddChoreViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/2/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import UIKit
import SwiftyFORM
import KumpeHelpers

class AddChoreViewController: FormViewController {

// MARK: Parameters
    var selectedUser: User?
    var day = "Weekly"

// MARK: loadView
    override func loadView() {
        super.loadView()
        installSubmitButton()
    }

// MARK: populate
    override func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Add Chore"
        builder.toolbarMode = .simple
        builder.demo_showInfo("Add a new chore for \(selectedUser!.firstName ?? "Selected User")")
        builder += dayOfWeek
        builder += choreName
        builder += choreDescription
        builder += blockDash
        builder += oneTime
        builder += optional
        builder += anyKid
        builder += startDate
    }

// MARK: dayOfWeek Selector
    lazy var dayOfWeek: ViewControllerFormItem = {
       let instance = ViewControllerFormItem()
            instance.title("Day Of Week").placeholder("required")
            instance.createViewController = { (dismissCommand: CommandProtocol) in
                let vc = DayOfWeekViewController(dismissCommand: dismissCommand)
                return vc
            }
            instance.willPopViewController = { (context: ViewControllerFormItemPopContext) in
                if let x = context.returnedObject as? SwiftyFORM.OptionRowFormItem {
                    context.cell.detailTextLabel?.text = x.title
                    self.day = x.title
                } else {
                    context.cell.detailTextLabel?.text = nil
                }
            }
            return instance
        }()

// MARK: choreName Field
    lazy var choreName: TextFieldFormItem = {
        let instance = TextFieldFormItem()
        instance.title("Chore Name").placeholder("required")
        instance.keyboardType = .asciiCapable
        instance.validate(CountSpecification.max(45), message: "Limit 45 characters")
        instance.submitValidate(CountSpecification.min(1), message: "Chore Name is required")
        return instance
    }()

// MARK: choreDescription Field
    lazy var choreDescription: TextFieldFormItem = {
        let instance = TextFieldFormItem()
        instance.title("Chore Description").placeholder("optional")
        instance.keyboardType = .asciiCapable
        instance.validate(CountSpecification.max(200), message: "Limit 200 characters")
        return instance
    }()

// MARK: blockDash Switch
    lazy var blockDash: SwitchFormItem = {
       let instance = SwitchFormItem()
        instance.title = "Block Dash Button"
        instance.value = false
        return instance
    }()

// MARK: oneTime Switch
    lazy var oneTime: SwitchFormItem = {
       let instance = SwitchFormItem()
        instance.title = "One Time Chore"
        instance.value = false
        return instance
    }()

// MARK: optional Switch
    lazy var optional: SwitchFormItem = {
       let instance = SwitchFormItem()
        instance.title = "Chore Is Optional"
        instance.value = false
        return instance
    }()

// MARK: anyKid Switch
    lazy var anyKid: SwitchFormItem = {
        let instance = SwitchFormItem()
        instance.title = "Chore Is for Any Kid"
        instance.value = false
        return instance
    }()

// MARK: startDate Date Picker
    lazy var startDate: DatePickerFormItem = {
        let instance = DatePickerFormItem()
        let today = Date()
        instance.title = "Chore Start Date"
        instance.datePickerMode = .date
        instance.value = today
        return instance
    }()

// MARK: submitForm
    func submitForm() {
        var username = "\(selectedUser!.username!)"
        if anyKid.value {
            username = "any"
        }
        KKidClient.addChore(username: username, choreName: choreName.value, choreDescription: choreDescription.value, blockDash: blockDash.value, oneTime: oneTime.value, optional: optional.value, startDate: startDate.value, day: day) { (success, error) in
            if success {
                dispatchOnMain {
                    self.navigationController?.popViewController(animated: true)
                }
                KKidClient.getChores(silent: true) { (_, _) in
                    return
                }
            } else {
                ShowAlert.banner(title: "Add Chore Error", message: error ?? "An Unknown Error Occurred")
            }
        }
    }

}

// MARK: - Submit Button Setup
extension AddChoreViewController {

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
