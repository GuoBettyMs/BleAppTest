//
//  PS200WorkingStatusResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class PS200WorkingStatusResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0x95
    var totalChannels = 0
    var timestamp = 0
    var workingStatusList:[WorkingStatusModel] = []
    var cmds: [UInt8] = []
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        cmds = cmd!
        workingStatusList.removeAll()
        var i:Int = 1
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        tmp = getByte(cmd: cmd, index: &i)
        totalChannels = Int(tmp)

        tmp = getByte(cmd: cmd, index: &i)
        timestamp = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        timestamp |= (Int(tmp) << 24)
        
        for _ in 0..<totalChannels {
            let workingStatusModel = WorkingStatusModel()
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.channelID = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.validIDBool = Int(tmp) == 1
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.channelType = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.fastChargeProtocol = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.reserve = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.reserve1 = Int(tmp)

            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputVoltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputVoltage |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputVoltage |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputVoltage |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputCurrent = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputCurrent |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputCurrent |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputCurrent |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.outputPower |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.maximumPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.maximumPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.maximumPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.maximumPower |= (Int(tmp) << 24)
            
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.currentPower = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.currentPower |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.currentPower |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            workingStatusModel.currentPower |= (Int(tmp) << 24)
            
            workingStatusList.append(workingStatusModel)
            
        }
    }
}
