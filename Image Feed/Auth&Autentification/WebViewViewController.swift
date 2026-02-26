//
//  WebViewViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 21.02.2026.
//

import UIKit
import WebKit

// MARK: - WebViewViewControllerDelegate Protocol
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewController Protocol
@MainActor
protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController {
    
    // MARK: - Private Properties
    private var webView: WKWebView?
    private let progressView = UIProgressView()
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Public Properties
    var presenter: WebViewPresenterProtocol?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
        setupProgressView()
        setupPresenter()
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        estimatedProgressObservation?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func setupPresenter() {
        if presenter == nil {
            let authHelper = AuthHelper()
            presenter = WebViewPresenter(authHelper: authHelper)
        }
        presenter?.view = self
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let customView = UIButton(type: .custom)
        customView.setImage(UIImage(resource: .backwardLogin), for: .normal)
        customView.tintColor = .ypBlack
        customView.backgroundColor = .ypWhite
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let customButton = UIBarButtonItem(customView: customView)
        navigationItem.leftBarButtonItem = customButton
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.webView = webView
    }
    
    private func setupProgressView() {
        progressView.progressTintColor = .ypBlack
        progressView.trackTintColor = .lightGray
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func observeProgress() {
        guard let webView = webView else { return }
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new],
             changeHandler: { [weak self] _, change in
                 guard let self = self,
                       let presenter = self.presenter,
                       let newValue = change.newValue else { return }
                 
                 presenter.didUpdateProgressValue(newValue)
             })
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WebViewViewController + WKNavigationDelegate, WKUIDelegate
extension WebViewViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let presenter = presenter,
              let code = presenter.code(from: navigationAction) else {
            decisionHandler(.allow)
            return
        }
        
        delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        decisionHandler(.cancel)
    }
}

// MARK: - WebViewViewController + WebViewViewControllerProtocol
extension WebViewViewController: WebViewViewControllerProtocol {
    func load(request: URLRequest) {
        webView?.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
