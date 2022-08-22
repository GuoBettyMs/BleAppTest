//
//  BindingResponse.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class BindingResponse: PackBase {
    
    static let CMD_WORD:UInt8 = 0x19
    var bound = 0
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        var i:Int = 0
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        tmp = getByte(cmd: cmd, index: &i)
        bound = Int(tmp)
        
    }
}
