//
//  WebViewPresenter.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.01.2026.
//

import UIKit
import WebKit

// MARK: - WebViewPresenter Protocol
protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from navigationAction: WKNavigationAction) -> String?
}

// MARK: - WebViewPresenter
final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Properties
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Initializer
    init(authHelper: AuthHelperProtocol = AuthHelper()) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    @MainActor func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    @MainActor func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        return authHelper.code(from: navigationAction)
    }
    
    // MARK: - Private Methods
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
