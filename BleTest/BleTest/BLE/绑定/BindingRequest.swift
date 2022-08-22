//
//  BindingRequest.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class BindingRequest: PackBase {
    
    private var cmd:[UInt8]?
    var uuid = ""
    var fastBinding = 0
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        let uuidTmp = UUID.init(uuidString: uuid)
        if nil == uuidTmp {
            return nil
        }

        cmd!.removeAll()
        assembleByte(cmd: &cmd, byte: UInt8(0x18))
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.0)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.1)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.2)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.3)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.4)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.5)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.6)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.7)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.8)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.9)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.10)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.11)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.12)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.13)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.14)
        assembleByte(cmd: &cmd, byte: uuidTmp!.uuid.15)
        assembleByte(cmd: &cmd, byte: UInt8(fastBinding))


        return cmd
        
    }
}
