//
//  OTAUpgradeCmdReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation

class OTAUpgradeCmdReq: PackBase {
    private var cmd:[UInt8]?
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        assembleByte(cmd: &cmd, byte: PackBase.ADDRESS)
        assembleByte(cmd: &cmd, byte: UInt8(0xF0))
        assembleByte(cmd: &cmd, byte: UInt8(0xAC))
        
        return cmd
        
    }
}
