//
//  RenameReq.swift
//  IOSApp
//
//  Created by gbt on 2022/5/11.
//

import Foundation

class RenameReq: PackBase {
    
    private var cmd:[UInt8]?
    var nameBytes:[UInt8] = []
    
    override func assemble() -> [UInt8]? {
        if nil == cmd {
            cmd = []
        }
        
        cmd!.removeAll()
        assembleByte(cmd: &cmd, byte: UInt8(PackBase.ADDRESS))
        assembleByte(cmd: &cmd, byte: UInt8(0xC0))
        
        for i in 0..<14 {
            if i < nameBytes.count {
                assembleByte(cmd: &cmd, byte: nameBytes[i])
            } else {
                assembleByte(cmd: &cmd, byte: 0)
            }
        }
                
        return cmd
        
    }
    
    func setName(name: String) {
        if "" == name || name.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        let bytes:[UInt8] = [UInt8](name.utf8)
        nameBytes.removeAll()
        for i in 0..<bytes.count {
            if i >= 14 {
                break
            }
            nameBytes.append(bytes[i])
        }
    }
}
