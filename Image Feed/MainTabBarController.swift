//
//  MainTabBarController.swift
//  temp_ImagesFeed
//
//  Created by Oschepkov Aleksandr on 19.01.2026.
//
import UIKit
final class MainTabBarController: UITabBarController {
    
    private let customTabBarHeight: CGFloat = 83
    private var customTabBar: CustomTabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        makeUI()
    }
    private func setupCustomTabBar() {
        tabBar.isHidden = true
        let tabItems = [
            UITabBarItem(title: "", image: UIImage(resource: .activeLenta), tag: 0),
            UITabBarItem(title: "", image: UIImage(resource: .activeProfile), tag: 1)
        ]
        customTabBar = CustomTabBar(items: tabItems)
        customTabBar.backgroundColor = .ypBlack
        customTabBar.height = customTabBarHeight
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        customTabBar.onItemSelected = { [weak self] index in
            self?.selectedIndex = index  // Переключаем вкладку
        }
        
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: customTabBarHeight)
        ])
    }
    private func makeUI() {
        let firstVC = ImagesListViewController()
        let secondVC = ProfileViewController()
        viewControllers = [firstVC, secondVC]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        guard let customTabBar = customTabBar else { return }
        customTabBar.selectedIndex = index
    }
}
