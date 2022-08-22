//
//  OTARebootReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation

class OTARebootReq: PackBase {
    
    private var cmd:[UInt8]?
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        assembleByte(cmd: &cmd, byte: PackBase.ADDRESS)
        assembleByte(cmd: &cmd, byte: UInt8(0xFC))
        assembleByte(cmd: &cmd, byte: UInt8(0xCA))
        
        return cmd
        
    }
}
