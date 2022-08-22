//
//  HardwareInformationResp.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation


class HardwareInformationResp: PackBase {
    
    static let CMD_WORD:UInt8 = 0xE1
    var bleBool = true
    var deviceId:[UInt8] = []
    var mainHardwareVersion = 0
    var subHardwareVersion = 0
    var mainSoftwareVersion = 0
    var subSoftwareVersion = 0
    var bootMainVersion = 0
    var bootSubVersion = 0
    var bootMendVersion = 0
    var bootCompileVersion = 0
    var appMainVersion = 0
    var appSubVersion = 0
    var appMendVersion = 0
    var appCompileVersion = 0
    
    var bleMainHardwareVersion = 0
    var bleSubHardwareVersion = 0
    var bleMainSoftwareVersion = 0
    var bleSubSoftwareVersion = 0
    var deviceID:Int64 = 0
    
    override func parse(cmd: [UInt8]?) {
        if nil == cmd {
            return
        }
        var i:Int = 0
        var tmp:UInt8 = 0
        tmp = getByte(cmd: cmd, index: &i)
        setCmdWord(cmdWord: tmp)
        
        if tmp == 225 {
            bleBool = true
            tmp = getByte(cmd: cmd, index: &i)
            bleMainHardwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bleSubHardwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bleMainSoftwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bleSubSoftwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID = Int64(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 8)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 16)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 24)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 32)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 40)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 48)
            tmp = getByte(cmd: cmd, index: &i)
            deviceID |= (Int64(tmp) << 56)
        } else {
            bleBool = false
            tmp = getByte(cmd: cmd, index: &i)
            setCmdWord(cmdWord: tmp)
            for _ in 0..<8 {
                tmp = getByte(cmd: cmd, index: &i)
                deviceId.append(tmp)
            }
            
            tmp = getByte(cmd: cmd, index: &i)
            mainHardwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            subHardwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            mainSoftwareVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            subSoftwareVersion = Int(tmp)
            
            tmp = getByte(cmd: cmd, index: &i)
            bootMainVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bootSubVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bootMendVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            bootCompileVersion = Int(tmp)
            
            tmp = getByte(cmd: cmd, index: &i)
            appMainVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            appSubVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            appMendVersion = Int(tmp)
            tmp = getByte(cmd: cmd, index: &i)
            appCompileVersion = Int(tmp)
            
        }
    }
}
