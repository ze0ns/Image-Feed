//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Oschepkov Aleksandr on 26.02.2026.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    @MainActor
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("логин")
        
        app.buttons["Next"].firstMatch.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("пароль")
        
        app.buttons["Next"].firstMatch.tap()
        
        webView.buttons["Login"].tap()

        sleep(10)
        
        let feedTable = app.tables.firstMatch
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Таблица ленты должна появиться после входа")

        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка ленты должна загрузиться")
        
        XCTAssertFalse(webView.exists, "WebView авторизации должен быть закрыт")
    }
    @MainActor
    func testProfile() throws {
        let app = XCUIApplication()
        app.activate()
        sleep(3)
        app/*@START_MENU_TOKEN@*/.buttons["ActiveProfile"]/*[[".otherElements.buttons[\"ActiveProfile\"]",".buttons[\"ActiveProfile\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        let authButton = app.buttons["Authenticate"]
        
        XCTAssertTrue(authButton.waitForExistence(timeout: 5),
                      "После выхода должен открыться экран авторизации с кнопкой Authenticate")
    }
    func testFeed() throws {
        let feedTable = app.tables["FeedTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Таблица ленты должна появиться")

        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка должна существовать")

        feedTable.swipeUp()
        feedTable.swipeDown()
    
        let likeButton = firstCell.buttons["LikeButton"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка должна быть в первой ячейке")
        
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        sleep(2)
        firstCell.tap()
        
        let singleImageElement = app.scrollViews["SingleImageScrollView"].firstMatch
        XCTAssertTrue(singleImageElement.waitForExistence(timeout: 5), "Экран просмотра картинки должен открыться")
        
        singleImageElement.pinch(withScale: 3.0, velocity: 1.0)
        singleImageElement.pinch(withScale: 0.5, velocity: -1.0)
        
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.exists, "Кнопка возврата должна быть")
        backButton.tap()
        
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Должны вернуться на экран ленты")
    }
}
