//
//  PS200DCStatusResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class PS200DCStatusResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0x97
    var timestamp = 0
    var totalChannels = 0
    var dCStatusList:[DCStatusModel] = []
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        
        var i:Int = 1
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        timestamp = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        totalChannels = Int(tmp)
        
        for _ in 0..<totalChannels {
            let dCStatusModel = DCStatusModel()
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.channelTypes = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.validID = Int(tmp)
            
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.voltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.voltage |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.voltage |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.voltage |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.current = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.current |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.current |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.current |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.maximumPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.maximumPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.maximumPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.maximumPower |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentPower |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentSetPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentSetPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentSetPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            dCStatusModel.currentSetPower |= (Int(tmp) << 24)
            
            dCStatusList.append(dCStatusModel)
        }
        
    }
}
