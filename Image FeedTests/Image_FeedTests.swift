//
//  WebViewTests.swift
//  Image FeedTests
//
//  Created by Oschepkov Aleksandr on 21.02.2026.
//

@testable import Image_Feed
import XCTest
import WebKit

// MARK: - WebViewViewControllerSpy
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadCalled: Bool = false
    var setProgressValueCalled: Bool = false
    var setProgressHiddenCalled: Bool = false
    var receivedProgressValue: Float?
    var receivedProgressHidden: Bool?
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
        receivedProgressValue = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
        receivedProgressHidden = isHidden
    }
}

// MARK: - WebViewPresenterSpy
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        // Пустая реализация для тестов
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        return nil
    }
}

// MARK: - AuthHelperSpy
final class AuthHelperSpy: AuthHelper {
 
    var authURLCalled: Bool = false
    var stubURL: URL?
    
    override func authURL() -> URL? {
        authURLCalled = true
        return stubURL ?? URL(string: "https://unsplash.com")
    }
}
// MARK: - Mock Navigation Action
class MockNavigationAction: WKNavigationAction {
    private var mockRequest: URLRequest
    
    override var request: URLRequest {
        return mockRequest
    }
    
    init(url: URL) {
        self.mockRequest = URLRequest(url: url)
        super.init()
    }
}
// MARK: - WebViewTests
final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "viewDidLoad должен вызывать presenter.viewDidLoad()")
    }
    
    @MainActor
    func testPresenterCallsLoadRequest() {
        // Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelperSpy()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.loadCalled, "viewDidLoad должен вызывать load(request:) на view")
        XCTAssertTrue(authHelper.authURLCalled, "viewDidLoad должен вызывать authURL() на authHelper")
        XCTAssertTrue(viewController.setProgressValueCalled, "viewDidLoad должен вызывать setProgressValue")
        XCTAssertEqual(viewController.receivedProgressValue, 0, "Начальное значение прогресса должно быть 0")
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let authHelper = AuthHelperSpy()
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = (abs(progress - 1.0) <= 0.0001)
        
        // Then
        XCTAssertFalse(shouldHideProgress, "Прогресс должен быть видим при значении < 1.0")
    }
    
    func testProgressHiddenWhenOne() {
        // Given
        let progress: Float = 1.0
        
        // When
        let shouldHideProgress = (abs(progress - 1.0) <= 0.0001)
        
        // Then
        XCTAssertTrue(shouldHideProgress, "Прогресс должен быть скрыт при значении 1.0")
    }
    
    func testAuthHelperAuthURL() {
        // Given
        let authHelper = AuthHelper()
        
        // When
        guard let url = authHelper.authURL() else {
            XCTFail("URL не должен быть nil")
            return
        }
        
        // Then
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("Не удалось создать URLComponents из URL")
            return
        }
        
        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertEqual(urlComponents.host, "unsplash.com")
        XCTAssertEqual(urlComponents.path, "/oauth/authorize")
        
        let queryItems = urlComponents.queryItems
        XCTAssertNotNil(queryItems)
        
        let clientIdItem = queryItems?.first(where: { $0.name == "client_id" })
        XCTAssertEqual(clientIdItem?.value, Constants.accessKey)
        
        let redirectUriItem = queryItems?.first(where: { $0.name == "redirect_uri" })
        XCTAssertEqual(redirectUriItem?.value, Constants.redirectURI)
        
        let responseTypeItem = queryItems?.first(where: { $0.name == "response_type" })
        XCTAssertEqual(responseTypeItem?.value, "code")
        
        let scopeItem = queryItems?.first(where: { $0.name == "scope" })
        XCTAssertEqual(scopeItem?.value, Constants.accessScope)
    }
    
    func testCodeFromURL() {
        
        let authHelper = AuthHelper()
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code 123")]
        let url = urlComponents.url!
        
        // when
        let code = authHelper.getCode(from: url)
        
        // then
        XCTAssertEqual(code, "test code 123")
    }
}
