//
//  UIBarButtonItem+Extension.swift
//  UIT
//
//  Created by Oschepkov Aleksandr on 09.04.2023.
//


import Foundation
import UIKit
extension UIBarButtonItem {

    static func menuButton(_ target: Any?, action: Selector, imageName: String, color: UIColor) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = color

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 73).isActive = true

        return menuBarItem
    }
}

