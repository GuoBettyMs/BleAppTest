//
//  Settings.swift
//  BattAir
//
//  Created by isdt on 2021/4/26.
//  Copyright © 2021 ISDT. All rights reserved.
//

import Foundation


class Settings: NSObject {
    
    @objc dynamic var beepBool = false
    @objc dynamic var shockBool = true
    @objc dynamic var showOfflineBool = true
    @objc dynamic var sortByNameBool = false
    var currentDevice = ""
    @objc dynamic static let sharedInstance = Settings()
    
}
