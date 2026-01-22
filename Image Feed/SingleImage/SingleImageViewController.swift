//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 20.01.2026.
//

import UIKit

class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var imageURL: UIImage? {
        didSet {
            imageView.image = imageURL
            guard  let imageURL else { return }
            imageView.frame.size = imageURL.size
            rescaleAndCenterImageInScrollView(image: imageURL)
        }
    }
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .backward), for: .normal)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToFirstScreen), for: .touchUpInside)
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .sharing), for: .normal)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        guard let imageURL else { return }
        imageView.image = imageURL
        imageView.frame.size = imageURL.size
        setupViews()
        setupConstraints()
        configureScrollView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard  let imageURL else { return }
        rescaleAndCenterImageInScrollView(image: imageURL)
    }
    
    // MARK: - Private Properties, configure UI
    private func setupViews() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // ImageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем в иерархию
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
    }
    // MARK: - Private Properties, configure Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView занимает весь экран
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            // ImageView внутри ScrollView
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // BackButton
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 53),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            // BackButton
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -61),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Private Properties, configure ScrollView
    private func configureScrollView() {
        scrollView.delegate = self
        guard  let imageURL else { return }
        let imageSize = imageURL.size
        let screenSize = UIScreen.main.bounds.size
        let widthRatio = screenSize.width / imageSize.width
        let heightRatio = screenSize.height / imageSize.height
        let minScale = max(widthRatio, heightRatio)
        scrollView.bounces = true
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.25
        scrollView.zoomScale = minScale
        
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    // MARK: - Actions
    @objc private func backToFirstScreen() {
        guard let navController = navigationController else { return }
        let sourceVC = MainTabBarController()
        navController.setViewControllers([sourceVC], animated: true)
    }
    @objc private func didTapShareButton(_ sender: UIButton) {
        guard let imageURL else { return }
        let share = UIActivityViewController(
            activityItems: [imageURL],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Центрируем изображение при зуме
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        imageView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
}
