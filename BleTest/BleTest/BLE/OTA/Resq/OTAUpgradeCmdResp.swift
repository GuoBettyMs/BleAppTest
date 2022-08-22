//
//  OTAUpgradeCmdResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class OTAUpgradeCmdResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0xF1
    var state = false
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        var i:Int = 1
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        state = Int(tmp) == 0
    }
}
