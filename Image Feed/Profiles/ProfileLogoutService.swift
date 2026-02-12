//
//  ProfileLogoutService.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 11.02.2026.
//


import Foundation
// Обязательный импорт
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
   private init() { }
   private var storageToken = OAuth2TokenStorage.shared
   
   func logout() {
      cleanCookies()
      storageToken.token = nil
      ImagesListService.shared.reset()
      ProfileImageService.shared.removeAvatar()
      ProfileService.shared.removeProfile()
   }

   private func cleanCookies() {
      // Очищаем все куки из хранилища
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      // Запрашиваем все данные из локального хранилища
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         // Массив полученных записей удаляем из хранилища
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
    
