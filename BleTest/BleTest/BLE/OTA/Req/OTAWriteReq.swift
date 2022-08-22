//
//  OTAWriteReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation

class OTAWriteReq: PackBase {
    
    private var cmd:[UInt8]?
    var startAddress:UInt32 = 0
    var data:[UInt8] = []
    var oldBool = false
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        if oldBool {
            assembleByte(cmd: &cmd, byte: PackBase.ADDRESS)
        }
        assembleByte(cmd: &cmd, byte: UInt8(0xF4))
        assembleByte(cmd: &cmd, byte: UInt8(0x00))
        
        assembleByte(cmd: &cmd, byte: UInt8(startAddress & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 8) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 16) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 24) & 0xFF))
        
        let dataSize = data.count
        
        for i in 0..<dataSize {
            assembleByte(cmd: &cmd, byte: data[i])
        }
        
        return cmd
        
    }
}
