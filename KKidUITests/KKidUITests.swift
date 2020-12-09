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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app.launch()
        sleep(3)
        if elementsQuery.buttons["Login"].exists {
            elementsQuery.textFields["Username"].tap()
            elementsQuery.buttons["Login"].tap()
            sleep(5)
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

    func testLogin() throws {
    }

    func testChores() throws {

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier:"Chores").element.tap()

        let thisWeekButton = app/*@START_MENU_TOKEN@*/.buttons["This Week"]/*[[".segmentedControls.buttons[\"This Week\"]",".buttons[\"This Week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        thisWeekButton.tap()

        let weeklyButton = app/*@START_MENU_TOKEN@*/.buttons["Weekly"]/*[[".segmentedControls.buttons[\"Weekly\"]",".buttons[\"Weekly\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        weeklyButton.tap()
        thisWeekButton.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Today"]/*[[".segmentedControls.buttons[\"Today\"]",".buttons[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        thisWeekButton.tap()
        weeklyButton.tap()
        thisWeekButton.tap()
        app.navigationBars["Chores"].buttons["Home"].tap()

    }

    func testAllowance() throws {

        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Allowance").element.tap()

        let allowanceNavigationBar = app.navigationBars["Allowance"]
        allowanceNavigationBar.buttons["Bookmarks"].tap()
        app.navigationBars["Allowance Transactions"].buttons["Allowance"].tap()
        allowanceNavigationBar.buttons["Home"].tap()

    }

    func testEditProfile() throws {

        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Edit Profile").element.tap()
        app.navigationBars["Edit Profile"].buttons["Home"].tap()

    }

    func testSelectUser() throws {

        let cellsQuery = app.collectionViews.cells
        let selectUserElement = cellsQuery.otherElements.containing(.staticText, identifier:"Select User").element
        selectUserElement.tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["John Doe"]/*[[".cells.staticTexts[\"John Doe\"]",".staticTexts[\"John Doe\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        selectUserElement.tap()
        app.navigationBars["Select User"].buttons["Home"].tap()

    }

    func testTmdb() throws {

        let scrollViewsQuery = app.scrollViews
        let collectionViewsQuery = app.collectionViews
        let cellsQuery = collectionViewsQuery.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Search Movies").element.tap()
        sleep(1)
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        scrollViewsQuery.children(matching: .button).element.tap()
        sleep(3)
        app.navigationBars["tmdb"].buttons["Search"].tap()
        app.navigationBars["Search Movies"].buttons["Home"].tap()

    }

    func testBuildScreenshots() throws {

        let collectionViewsQuery = app.collectionViews
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Logout").element.tap()
        setupSnapshot(app)
        app.launch()
        sleep(3)
        snapshot("LoginScreen")

        //Login
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["Username"].tap()
        elementsQuery.buttons["Login"].tap()
        sleep(5)

        snapshot("HomeScreen")

        cellsQuery.otherElements.containing(.staticText, identifier:"Chores").element.tap()
        app/*@START_MENU_TOKEN@*/.buttons["This Week"]/*[[".segmentedControls.buttons[\"This Week\"]",".buttons[\"This Week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(5)
        snapshot("ChoresScreen")
        app.navigationBars["Chores"].buttons["Home"].tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Allowance").element.tap()
        sleep(5)
        snapshot("AllowanceScreen")
        app.navigationBars["Allowance"].buttons["Home"].tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Select User").element.tap()
        sleep(5)
        snapshot("SelectUserScreen")
        app.navigationBars["Select User"].buttons["Home"].tap()
        cellsQuery.otherElements.containing(.staticText, identifier:"Search Movies").element.tap()
        sleep(1)
        snapshot("SearchMovies")
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        sleep(1)
        snapshot("MovieDetails")
        app.navigationBars["tmdb"].buttons["Search"].tap()
        app.navigationBars["Search Movies"].buttons["Home"].tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
