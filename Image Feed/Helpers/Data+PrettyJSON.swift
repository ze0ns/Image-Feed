//
//  Data+PrettyJSON.swift
//  client-server-1436
//
//  Created by Oschepkov Aleksandr on 19.08.2021.
//
//Необходим для нормализации ответа JSON. После чего его можно превратить в модель через app.quicktype.io

import Foundation

 extension Data {
     var prettyJSON: NSString? {
         guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
               let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
               let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

         return prettyPrintedString
     }
 }
