//
//  OTAWriteResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class OTAWriteResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0xF5
    var state = 0
    var cpuIndex = 0
    var statAddress:UInt32 = 0
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        var i:Int = 1
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        cpuIndex = Int(tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        statAddress = UInt32(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        statAddress |= (UInt32(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        statAddress |= (UInt32(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        statAddress |= (UInt32(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        state = Int(tmp)
    }
}
