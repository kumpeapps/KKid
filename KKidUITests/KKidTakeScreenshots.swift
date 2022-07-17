//
//  KKidTakeScreenshots.swift
//  KKidUITests
//
//  Created by Justin Kumpe on 3/10/22.
//  Copyright © 2022 Justin Kumpe. All rights reserved.
//

import XCTest

class KKidTakeScreenshots: XCTestCase {

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
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Logout").element.tap()
        app.buttons["dismiss"].tap()
    }

    func testBuildScreenshots() throws {

        let collectionViewsQuery = app.collectionViews
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Logout").element.tap()
        setupSnapshot(app)
        app.launch()
        sleep(3)
        snapshot("LoginScreen")

        // Login
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["Username"].tap()
        elementsQuery.buttons["Login"].tap()
        sleep(5)

        snapshot("HomeScreen")

        cellsQuery.otherElements.containing(.staticText, identifier:"Chores").element.tap()
        app/*@START_MENU_TOKEN@*/.buttons["This Week"]/*[[".segmentedControls.buttons[\"This Week\"]",".buttons[\"This Week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(5)
        snapshot("ChoresScreen")
        app.navigationBars["KKid.ChoresView"].buttons["Home"].tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Allowance").element.tap()
        sleep(5)
        snapshot("AllowanceScreen")
        app.navigationBars["KKid.AllowanceView"].buttons["Home"].tap()
        sleep(2)
        app.buttons["avatar"].tap()
        sleep(5)
        snapshot("SelectUserScreen")
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Jane D").children(matching: .other).element.tap()

        cellsQuery.otherElements.containing(.staticText, identifier:"Movies DB").element.tap()
        sleep(1)
        snapshot("SearchMovies")
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        sleep(1)
        snapshot("MovieDetails")
        app.navigationBars["tmdb"].buttons["Back"].tap()
        app.navigationBars["Movies DB"].buttons["Home"].tap()
    }
}
