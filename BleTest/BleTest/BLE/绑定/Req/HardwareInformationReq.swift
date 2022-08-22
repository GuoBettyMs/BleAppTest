//
//  HardwareInformationReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class HardwareInformationReq: PackBase {
    
    private var cmd:[UInt8]?
    var bleBool = true
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        if bleBool {
            assembleByte(cmd: &cmd, byte: UInt8(0xE0))
        }else {
            assembleByte(cmd: &cmd, byte: PackBase.ADDRESS)
            assembleByte(cmd: &cmd, byte: UInt8(0xE0))
        }

        return cmd
        
    }
}
