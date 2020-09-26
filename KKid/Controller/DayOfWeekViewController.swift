//
//  DayOfWeekViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 9/16/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

// MIT license. Copyright (c) 2020 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM

struct OptionRow {
    let title: String
    let identifier: String

    init(_ title: String, _ identifier: String) {
        self.title = title
        self.identifier = identifier
    }
}

class MyOptionForm {
    let optionRows: [OptionRow]

    init(optionRows: [OptionRow]) {
        self.optionRows = optionRows
    }

    func populate(_ builder: FormBuilder) {
        builder.navigationTitle = "Picker"


        for optionRow: OptionRow in optionRows {
            let option = OptionRowFormItem()
            option.title = optionRow.title
            builder.append(option)
        }

        
    }

}

class DayOfWeekViewController: FormViewController, SelectOptionDelegate {
    var xmyform: MyOptionForm?

    let dismissCommand: CommandProtocol

    init(dismissCommand: CommandProtocol) {
        self.dismissCommand = dismissCommand
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func populate(_ builder: FormBuilder) {
        let optionRows: [OptionRow] = [
            OptionRow("Sunday", "Sunday"),
            OptionRow("Monday", "Monday"),
            OptionRow("Tuesday", "Tuesday"),
            OptionRow("Wednesday", "Wednesday"),
            OptionRow("Thursday", "Thursday"),
            OptionRow("Friday", "Friday"),
            OptionRow("Saturday", "Saturday"),
            OptionRow("Weekly", "Weekly")
        ]

        let myform = MyOptionForm(optionRows: optionRows)

        myform.populate(builder)
        xmyform = myform
    }

    func form_willSelectOption(option: OptionRowFormItem) {
        dismissCommand.execute(viewController: self, returnObject: option)
    }

}

class EmptyViewController: UIViewController {

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.red
    }

}
