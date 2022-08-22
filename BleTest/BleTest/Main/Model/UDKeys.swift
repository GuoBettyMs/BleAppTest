//
//  UDKeys.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import UIKit

class UDKeys {
    
    struct ListInfo {
        static let showOffline = "showOffline"
        static let sortByName = "sortByName"
    }
    
    struct NotificationInfo {
        static let beep = "beep"
        static let shock = "shock"
    }
    
    struct UserDefaultKeys {

        enum ListInfo: String {
            case showOffline
            case sortByName
        }
        
        enum NotificationInfo: String {
            case beep
            case shock
        }
        
    }
    
}
