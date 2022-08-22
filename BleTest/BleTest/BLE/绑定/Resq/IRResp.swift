//
//  IRResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class IRResp: PackBase {
    static let CMD_WORD:UInt8 = 0xFB
    var channelId = 0
    var iRArray:[Int] = []
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        var i:Int = 1
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        channelId = Int(tmp)
        
        iRArray.removeAll()
        for _ in 0..<16 {
            var tmpInt = 0
            tmp = getByte(cmd: cmd, index: &i)
            tmpInt = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            tmpInt |= (Int(tmp) << 8)
            iRArray.append(tmpInt)
        }
        
    }
}
