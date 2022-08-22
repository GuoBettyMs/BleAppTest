//
//  ElectricResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class ElectricResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0xE5
    var channelId = 0
    var inputVoltage = 0
    var inputCurrent = 0
    var outputVoltage = 0
    var chargingCurrent = 0
    var cellVoltageList = [UInt16]()
    var cell = 8
    
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
        
        if cmd!.count > 35 {
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage |= (Int(tmp) << 24)
            cell = 16
        }else {
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            inputVoltage |= (Int(tmp) << 8)
        }
        
        tmp = getByte(cmd: cmd, index: &i)
        inputCurrent = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        inputCurrent |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        inputCurrent |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        inputCurrent |= (Int(tmp) << 24)
        
        if cmd!.count > 35 {
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage |= (Int(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage |= (Int(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage |= (Int(tmp) << 24)
        }else {
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            outputVoltage |= (Int(tmp) << 8)
        }
        
        tmp = getByte(cmd: cmd, index: &i)
        chargingCurrent = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        chargingCurrent |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        chargingCurrent |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        chargingCurrent |= (Int(tmp) << 24)
        
        for _ in 0..<cell {
            var tmpU16:UInt16 = 0
            tmp = getByte(cmd: cmd, index: &i)
            tmpU16 |= UInt16(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            tmpU16 |= (UInt16(tmp) << 8)
            cellVoltageList.append(tmpU16)
            
        }
        
//        Logger.debug("CH:\(channelId)   data.inputCurrent\(inputCurrent)  data.inputVoltage\(inputVoltage)")

    }
}
