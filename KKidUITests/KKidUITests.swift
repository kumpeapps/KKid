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
        let cellsQuery = app.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Chores").element.tap()

        let thisWeekButton = app/*@START_MENU_TOKEN@*/.buttons["This Week"]/*[[".segmentedControls.buttons[\"This Week\"]",".buttons[\"This Week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        thisWeekButton.tap()

        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["Weekly"]/*[[".segmentedControls.buttons[\"Weekly\"]",".buttons[\"Weekly\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        thisWeekButton.tap()
        app2.tables/*@START_MENU_TOKEN@*/.staticTexts["teat (Wednesday)"]/*[[".cells.staticTexts[\"teat (Wednesday)\"]",".staticTexts[\"teat (Wednesday)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        let checkScrollView = app/*@START_MENU_TOKEN@*/.scrollViews.containing(.button, identifier:"check").element/*[[".scrollViews.containing(.other, identifier:\"Vertical scroll bar, 2 pages\").element",".scrollViews.containing(.button, identifier:\"red x\").element",".scrollViews.containing(.button, identifier:\"x\").element",".scrollViews.containing(.button, identifier:\"blue dash\").element",".scrollViews.containing(.button, identifier:\"dash\").element",".scrollViews.containing(.button, identifier:\"green check\").element",".scrollViews.containing(.button, identifier:\"check\").element"],[[[-1,6],[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        checkScrollView.swipeDown()
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

        let collectionViewsQuery = app.collectionViews
        let cellsQuery = collectionViewsQuery.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"Movies DB").element.tap()
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        app.navigationBars["tmdb"].buttons["Back"].tap()

        let app2 = app
        app2/*@START_MENU_TOKEN@*/.buttons["Favorites"]/*[[".segmentedControls.buttons[\"Favorites\"]",".buttons[\"Favorites\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Watch List"]/*[[".segmentedControls.buttons[\"Watch List\"]",".buttons[\"Watch List\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app2/*@START_MENU_TOKEN@*/.buttons["Search"]/*[[".segmentedControls.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Movies DB"].buttons["Home"].tap()

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

        cellsQuery.otherElements.containing(.staticText, identifier:"Movies DB").element.tap()
        sleep(1)
        snapshot("SearchMovies")
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        sleep(1)
        snapshot("MovieDetails")
        app.navigationBars["tmdb"].buttons["Back"].tap()
        app.navigationBars["Movies DB"].buttons["Home"].tap()
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
