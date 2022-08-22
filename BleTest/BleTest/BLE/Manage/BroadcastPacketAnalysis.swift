//
//  BroadcastPacketAnalysis.swift
//  IOSApp
//
//  Created by gbt on 2022/5/9.
//
//  广播包

import Foundation

class BroadcastPacketAnalysis: NSObject{

        var cmdBytes:[UInt8] = []
        
        var manufacturerID = 0      
        var deviceModelID = ""
        var name = ""
        var rssi: NSNumber = -99
        
        init (bytes:[UInt8]?) {
            
            if bytes == nil {
                super.init()
                return
            }else {
                
                cmdBytes = bytes!
                var i:Int = 0
                
                func getByte(cmd: [UInt8]?, index: inout Int) -> UInt8 {
                    if nil == cmd {
                        return UInt8(0)
                    }
                    if index < cmd!.count {
                        let ret = cmd![index]
                        index += 1
                        return ret
                    } else {
                        return UInt8(0)
                    }
                }
                
                
                var tmp:UInt8 = 0
                tmp = getByte(cmd: cmdBytes, index: &i)
                manufacturerID = Int(tmp)
                tmp = getByte(cmd: cmdBytes, index: &i)
                manufacturerID |= (Int(tmp) << 8)
                tmp = getByte(cmd: cmdBytes, index: &i)
                manufacturerID |= (Int(tmp) << 16)
                tmp = getByte(cmd: cmdBytes, index: &i)
                manufacturerID |= (Int(tmp) << 24)
                
                tmp = getByte(cmd: cmdBytes, index: &i)
                deviceModelID.append(String(format: "%02x", tmp))
                tmp = getByte(cmd: cmdBytes, index: &i)
                deviceModelID.append(String(format: "%02x", tmp))
                tmp = getByte(cmd: cmdBytes, index: &i)
                deviceModelID.append(String(format: "%02x", tmp))
                tmp = getByte(cmd: cmdBytes, index: &i)
                deviceModelID.append(String(format: "%02x", tmp))
                
                
                var nameBytes:[UInt8] = []
                for _ in 0..<14 {
                    tmp = getByte(cmd: cmdBytes, index: &i)
                    nameBytes.append(tmp)
                }
                if !nameBytes.isEmpty {
                    name = String(bytes: nameBytes, encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? "ISDT"
                }else{
                    name = "ISDT"
                }
            }
            
            super.init()
        }
        

}
