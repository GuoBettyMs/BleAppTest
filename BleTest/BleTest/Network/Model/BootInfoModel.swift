//
//  BootInfoModel.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import UIKit

class BootInfoModel: NSObject {
    var type = "A"
    @objc dynamic var offset = 0
    @objc dynamic var blockSize = 0
    var support0x85Instruction = 0
    var appID = 0
    
    func clear() {
        type = "A"
        offset = 0
        blockSize = 0
        support0x85Instruction = 0
        appID = 0
    }
}
