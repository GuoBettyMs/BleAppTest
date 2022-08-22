//
//  PackSend.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class PackSend {
    var sent:Bool
    var sendContent:[UInt8]?
    var timeStamp:TimeInterval
    
    init(content: [UInt8]?) {
        sendContent = content
        sent = false
        timeStamp = Date().timeIntervalSince1970
    }
}
