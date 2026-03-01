//
//  accessibilityIdentifier.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 01.03.2026.
//

import Foundation

struct AIdent{
    static let shared = AIdent()
    private init() {}
    let webViewIdentifier = "UnsplashWebView"
    let buttonAuthIdeIdentifier = "Authenticate"
    let buttonBackIdentifier  = "BackButton"
    let scrollViewIdeIdentifier = "SingleImageScrollView"
    let buttonExitIdeIdentifier  = "logout button"
    let userFIOIdeIdentifier  = "Name Lastname"
    let loginNameIdeIdentifier  = "@username"
    let buttonLikeIdentifier = "LikeButton"
    let tableViewIdeIdentifier = "FeedTable"
}
