//
//  ChargerWorkStateResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class ChargerWorkStateResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0xE7
    var channelId = 0
    var workState = 0
    var capacityPercentage = 0
    var capacityDone = 0
    var energyDone = 0
    var workPeriod = 0
    var batteryType = 0
    var unitSerialsNum = 0
    var linkType = 0
    var fullChargedVolt = 0
    var workCurrent = 0
    var chargingBatteryNumWhole = 0
    var workNumberBatteries = 0
    var minInputVolt = 0
    var maxOutputPower = 0
    var errorCode = 0xFF
    var parallelState = 0
    
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
        tmp = getByte(cmd: cmd, index: &i)
        workState = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        capacityPercentage = Int(tmp)
        
        tmp = getByte(cmd: cmd, index: &i)
        capacityDone = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        capacityDone |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        capacityDone |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        capacityDone |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        energyDone = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        energyDone |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        energyDone |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        energyDone |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        workPeriod = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        workPeriod |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        workPeriod |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        workPeriod |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        batteryType = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        unitSerialsNum = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        linkType = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        fullChargedVolt = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        fullChargedVolt |= (Int(tmp) << 8)
        
        tmp = getByte(cmd: cmd, index: &i)
        workCurrent = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        workCurrent |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        workCurrent |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        workCurrent |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        chargingBatteryNumWhole = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        chargingBatteryNumWhole |= (Int(tmp) << 8)
        
        tmp = getByte(cmd: cmd, index: &i)
        workNumberBatteries = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        workNumberBatteries |= (Int(tmp) << 8)
        
        tmp = getByte(cmd: cmd, index: &i)
        minInputVolt = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        minInputVolt |= (Int(tmp) << 8)
        
        tmp = getByte(cmd: cmd, index: &i)
        maxOutputPower = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        maxOutputPower |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        maxOutputPower |= (Int(tmp) << 16)
        tmp = getByte(cmd: cmd, index: &i)
        maxOutputPower |= (Int(tmp) << 24)
        
        tmp = getByte(cmd: cmd, index: &i)
        errorCode = Int(tmp)
        tmp = getByte(cmd: cmd, index: &i)
        errorCode |= (Int(tmp) << 8)
        tmp = getByte(cmd: cmd, index: &i)
        parallelState = Int(tmp)
        
    }
}
