//
//  OTAChecksumReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation

class OTAChecksumReq: PackBase {
    
    private var cmd:[UInt8]?
    var startAddress:UInt32 = 0
    var size:UInt32 = 0
    var appChecksum:UInt32 = 0
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        assembleByte(cmd: &cmd, byte: PackBase.ADDRESS)
        assembleByte(cmd: &cmd, byte: UInt8(0xF6))
        assembleByte(cmd: &cmd, byte: UInt8(0x35))
        assembleByte(cmd: &cmd, byte: 0)
        
        assembleByte(cmd: &cmd, byte: UInt8(startAddress & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 8) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 16) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((startAddress >> 24) & 0xFF))
        
        assembleByte(cmd: &cmd, byte: UInt8(size & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((size >> 8) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((size >> 16) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((size >> 24) & 0xFF))
        
        assembleByte(cmd: &cmd, byte: UInt8(appChecksum & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((appChecksum >> 8) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((appChecksum >> 16) & 0xFF))
        assembleByte(cmd: &cmd, byte: UInt8((appChecksum >> 24) & 0xFF))
        
        return cmd
        
    }
}
