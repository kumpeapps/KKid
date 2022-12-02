//
//  KKidUITests.swift
//  KKidUITests
//
//  Created by Justin Kumpe on 11/8/20.
//  Copyright © 2020 Justin Kumpe. All rights reserved.
//

import XCTest

class KKidUITests: XCTestCase {

    let app = XCUIApplication()
    let elementsQuery = XCUIApplication().scrollViews.otherElements

    override func setUpWithError() throws {
        app.setSeenTutorial(true)
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.launch()
        let tos = app.buttons["Agree"]
        if tos.waitForExistence(timeout: 5) {
            tos.tap()
        }
        if elementsQuery.buttons["Login"].waitForExistence(timeout: 10) {
            elementsQuery.textFields["Username"].tap()
            elementsQuery.buttons["Login"].tap()
            if app.staticTexts["Continue"].waitForExistence(timeout:7) {
                app/*@START_MENU_TOKEN@*/.staticTexts["Continue"]/*[[".buttons[\"Continue\"].staticTexts[\"Continue\"]",".staticTexts[\"Continue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            }

        }

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let logout = app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Logout").element
        logout.waitTap(application: app, wait: 5, canFail: true)
    }

    func testLogin() throws {
    }

    func testChores() throws {
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Chores").element.tap()

        let thisWeekButton = app/*@START_MENU_TOKEN@*/.buttons["This Week"]/*[[".segmentedControls.buttons[\"This Week\"]",".buttons[\"This Week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        thisWeekButton.tap()

        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["Weekly"]/*[[".segmentedControls.buttons[\"Weekly\"]",".buttons[\"Weekly\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        thisWeekButton.tap()
        app.navigationBars["KKid.ChoresView"].buttons["Home"].tap()
    }

/*    func testAllowance() throws {

        let cellsQuery = app.collectionViews.cells
        let allowanceMod = cellsQuery.otherElements.containing(.staticText, identifier:"Allowance").element
        if allowanceMod.waitForExistence(timeout: 10) {
            allowanceMod.tap()
        }
        let kkidAllowanceviewNavigationBar = app.navigationBars["KKid.AllowanceView"]
        let bookmarksButton = kkidAllowanceviewNavigationBar.buttons["Bookmarks"]
        if bookmarksButton.waitForExistence(timeout: 10) {
            bookmarksButton.forceTapElement()
        }
        let backButton = app.navigationBars["Allowance Transactions"].buttons["Back"]
        if backButton.waitForExistence(timeout: 10) {
            backButton.tap()
        }

        let addButton = kkidAllowanceviewNavigationBar.buttons["Add"]
        if addButton.waitForExistence(timeout: 10) {
            addButton.tap()
        }

        if app.staticTexts["Continue"].waitForExistence(timeout: 4) {
            app.staticTexts["Continue"].tap()
        }

        let tablesQuery = app.tables
        let subtract = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Subtract"]/*[[".cells.staticTexts[\"Subtract\"]",".staticTexts[\"Subtract\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        if subtract.waitForExistence(timeout: 10) {
            subtract.forceTapElement()
        }
        app.pickerWheels["Subtract"].adjust(toPickerWheelValue: "Subtract")
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Transaction Type").element/*[[".cells.containing(.staticText, identifier:\"Add\").element",".cells.containing(.staticText, identifier:\"Transaction Type\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitTap(application: app, wait: 10, canFail: true)
        let amountField = tablesQuery.cells.containing(.staticText, identifier:"Amount  $").children(matching: .textField).element
        let textField = tablesQuery.cells.containing(.staticText, identifier:"Reason").children(matching: .textField).element
        amountField.waitTap(application: app, wait: 10, canFail: true)
        textField.waitTap(application: app, wait: 10, canFail: true)

        if app.staticTexts["Continue"].waitForExistence(timeout: 4) {
            app.staticTexts["Continue"].tap()
        }
        amountField.pasteTextFieldText(app: app, element: amountField, value: "5", clearText: false)

        if app.staticTexts["Continue"].waitForExistence(timeout: 4) {
            app.staticTexts["Continue"].tap()
        }
        if textField.waitForExistence(timeout: 10) {
            textField.pasteTextFieldText(app: app, element: textField, value: "Game", clearText: false)
        }

        let addTransactionNavigationBar = app.navigationBars["Add Transaction"]
        let addTrans = addTransactionNavigationBar.buttons["Submit"]
        if addTrans.waitForExistence(timeout: 10) {
            addTrans.tap()
        }
        if addButton.waitForExistence(timeout: 10) {
            addButton.tap()
        }

        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Subtract"]/*[[".cells.staticTexts[\"Subtract\"]",".staticTexts[\"Subtract\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitTap(application: app, wait: 10, canFail: true)
        app.pickerWheels["Subtract"].adjust(toPickerWheelValue: "Add")
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Transaction Type").element/*[[".cells.containing(.staticText, identifier:\"Add\").element",".cells.containing(.staticText, identifier:\"Transaction Type\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitTap(application: app, wait: 10, canFail: true)
        amountField.waitTap(application: app, wait: 10, canFail: true)
        amountField.pasteTextFieldText(app: app, element: amountField, value: "5", clearText: false)
        if textField.waitForExistence(timeout: 10) {
            textField.tap()
            textField.pasteTextFieldText(app: app, element: textField, value: "Game Refund", clearText: false)
        }
        if addTrans.waitForExistence(timeout: 10) {
            addTrans.tap()
        }
        if bookmarksButton.waitForExistence(timeout: 10) {
            bookmarksButton.forceTapElement()
        }
        if backButton.waitForExistence(timeout: 10) {
            backButton.tap()
        }
        if addButton.waitForExistence(timeout: 10) {
            addButton.tap()
        }
        addTransactionNavigationBar.buttons["Back"].waitTap(application: app, wait: 10, canFail: true)
        kkidAllowanceviewNavigationBar.buttons["Home"].waitTap(application: app, wait: 10, canFail: true)

    }*/

    func testEditProfile() throws {

        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Edit Profile").element.waitTap(application: app, wait: 10, canFail: true)
        app.navigationBars["Edit Profile"].buttons["Home"].waitTap(application: app, wait: 10, canFail: true)

    }

    func testSelectUser() throws {

        let app = XCUIApplication()
        app.buttons["avatar"].waitTap(application: app, wait: 10, canFail: true)
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Joey D").children(matching: .other).element.waitTap(application: app, wait: 10, canFail: true)

    }

/*    func testWishList() throws {

        let wishlistButton = app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Wish List").element
        if wishlistButton.waitForExistence(timeout: 10) {
            wishlistButton.tap()
        }

        let wishListNavigationBar = app.navigationBars["Wish List"]
        if wishListNavigationBar.waitForExistence(timeout: 10) {
            wishListNavigationBar.buttons["Share"].tap()
        }

        let popoversQuery = app.popovers
        let allusersButton = popoversQuery.sheets["Share Wish List"].scrollViews.otherElements.buttons["Household (all users)"]
        let allusersButtonPhone = app.sheets["Share Wish List"].scrollViews.otherElements.buttons["Household (all users)"]
        if allusersButtonPhone.waitForExistence(timeout: 5) {
            allusersButtonPhone.tap()
            let copyButton = app/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"ActivityListView\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Copy"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2)
            if copyButton.waitForExistence(timeout: 30) {
                copyButton.tap()
            }
        } else if allusersButton.waitForExistence(timeout: 5) {
            allusersButton.tap()
            let copyButton = popoversQuery/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"ActivityListView\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Copy"]
            if copyButton.waitForExistence(timeout: 30) {
                copyButton.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).tap()
            }
        }

        wishListNavigationBar.buttons["Home"].tap()
    }*/

    func testTmdb() throws {

        let collectionViewsQuery = app.collectionViews
        let cellsQuery = collectionViewsQuery.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Movies DB").element.waitTap(application: app, wait: 10, canFail: true)
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.waitTap(application: app, wait: 10, canFail: true)
        app.navigationBars["tmdb"].buttons["Back"].waitTap(application: app, wait: 10, canFail: true)

        app/*@START_MENU_TOKEN@*/.buttons["Favorites"]/*[[".segmentedControls.buttons[\"Favorites\"]",".buttons[\"Favorites\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Watch List"]/*[[".segmentedControls.buttons[\"Watch List\"]",".buttons[\"Watch List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Search"]/*[[".segmentedControls.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Movies DB"].buttons["Home"].tap()

    }

    func testLaunchPerformance() throws {
        /*if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }*/
    }

    func tapCoordinate(at xCoordinate: Double, and yCoordinate: Double) {
        let normalized = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let coordinate = normalized.withOffset(CGVector(dx: xCoordinate, dy: yCoordinate))
        coordinate.tap()
    }
}

extension XCUIElement {
    // The following is a workaround for inputting text in the
    // simulator when the keyboard is hidden
    func setText(text: String, application: XCUIApplication) {
        UIPasteboard.general.string = text
        doubleTap()
        if application.menuItems["Paste"].waitForExistence(timeout: 10) {
            application.menuItems["Paste"].tap()
        }
    }

    func labelContains(text: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return staticTexts.matching(predicate).firstMatch.exists
    }

    func forceTapElement() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }

    func pasteTextFieldText(app:XCUIApplication, element:XCUIElement, value:String, clearText:Bool) {
        // Get the password into the pasteboard buffer
        UIPasteboard.general.string = value

        // Bring up the popup menu on the password field
        element.tap()

        if clearText {
            element.buttons["Clear text"].tap()
        }

        element.doubleTap()

        // Tap the Paste button to input the password
        if app.menuItems["Paste"].waitForExistence(timeout: 5) {
            app.menuItems["Paste"].tap()
        } else {
            element.doubleTap()
            if app.menuItems["Paste"].waitForExistence(timeout: 10) {
                app.menuItems["Paste"].tap()
            }
        }
    }

    func waitTap(application: XCUIApplication, wait: TimeInterval, canFail: Bool) {
        if self.waitForExistence(timeout: wait) {
            self.forceTapElement()
        } else if canFail {
            XCTFail("button \(self.label) does not exist so can not be tapped")
        }
    }

}

extension XCUIApplication {
    func setSeenTutorial(_ seenTutorial: Bool = true) {
        guard seenTutorial else {
            return
        }
        launchArguments += ["-lastBuildHome", "999999"]
        launchArguments += ["-lastBuildChores", "999999"]
        launchArguments += ["-lastBuildMarkChore", "999999"]
        launchArguments += ["-lastBuildAllowance", "999999"]
        launchArguments += ["-lastBuildWishList", "999999"]
    }
}
