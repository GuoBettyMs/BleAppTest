//
//  PackBase.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class PackBase {
    
    static var packList:[PackBase] = []
    static var packSendList:[PackSend] = []
    static let packListLock = NSRecursiveLock()
    static let packSendListLock = NSRecursiveLock()
    static var ADDRESS: UInt8 = 0x13
    
    /* Isdt protocol */
    //static var buffer: [UInt8] = []
    
    var cmdWord:UInt8 = 0
    var readFlag: Bool = false
    var timeStamp:TimeInterval = 0
    
    
    //Filter out more than two consecutive 0xAA
    func assembleByte(cmd: inout [UInt8]?, byte: UInt8) {
        if nil == cmd {
            return
        }
//
//        if 0xAA == byte {
//            cmd?.append(byte)
//        }
        cmd?.append(byte)
    }
    
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
    
    func setCmdWord(cmdWord: UInt8) {
        self.cmdWord = cmdWord
    }
    
    func parse(cmd: [UInt8]?) {
        
    }
    
    func assemble() -> [UInt8]? {
        return nil
    }
    
    static func createInstance(_ cmd: [UInt8]) -> PackBase? {
        var packBaseRet: PackBase? = nil
        
        if cmd[0] != 49 {
            
            switch cmd[0] {
            case BindingResponse.CMD_WORD:
                packBaseRet = BindingResponse()
            case HardwareInformationResp.CMD_WORD:
                packBaseRet = HardwareInformationResp()
            default:
                packBaseRet = nil
            }
            
        }else {
            switch cmd[1] {
            case RenameResp.CMD_WORD:
                packBaseRet = RenameResp()
            case HardwareInformationResp.CMD_WORD:
                packBaseRet = HardwareInformationResp()
            case OTAUpgradeCmdResp.CMD_WORD:
                packBaseRet = OTAUpgradeCmdResp()
            case OTAEraseResp.CMD_WORD:
                packBaseRet = OTAEraseResp()
            case OTAWriteResp.CMD_WORD:
                packBaseRet = OTAWriteResp()
            case OTAChecksumResp.CMD_WORD:
                packBaseRet = OTAChecksumResp()
            case OTARebootResp.CMD_WORD:
                packBaseRet = OTARebootResp()
            case ElectricResp.CMD_WORD:
                packBaseRet = ElectricResp()
            case WorkTasksResp.CMD_WORD:
                packBaseRet = WorkTasksResp()
            case ChargerWorkStateResp.CMD_WORD:
                packBaseRet = ChargerWorkStateResp()
            case IRResp.CMD_WORD:
                packBaseRet = IRResp()
            case AlarmToneResp.CMD_WORD:
                packBaseRet = AlarmToneResp()
            case AlarmToneTaskResp.CMD_WORD:
                packBaseRet = AlarmToneTaskResp()
            default:
                packBaseRet = nil
            }
            
        }
        
        if nil != packBaseRet {
            packBaseRet!.timeStamp = Date().timeIntervalSince1970
            packBaseRet!.parse(cmd: cmd)
        }
        return packBaseRet
    }
    
    
    
    // MARK: 发送数据处理
    class func assemblePackSend(packBase: PackBase?) -> PackSend? {
        var packSendRet:PackSend? = nil
        packSendListLock.lock()
        
        if nil == packBase {
            return nil
        }
        let cmdList = packBase!.assemble()
        if nil == cmdList {
            return nil
        }
        packSendList.removeAll()
        packSendList.append(PackSend(content: cmdList))
        
        if packSendList.count > 0 {
            packSendRet = packSendList[0]
        }
        packSendListLock.unlock()
        
        return packSendRet
    }
    
    
    // MARK: 接收数据处理
    class func parsePack(_ data: [UInt8]) -> PackBase? {
        var packBaseTmp: PackBase? = nil
        packListLock.lock()
        if data.isEmpty {
            return nil
        }
        packList.removeAll()
        
        var s = ""
        for i in 0..<data.count {
            s += String(format: "%02x ", data[i])
        }
        Logger.debug("start write收到: " + s)
        
        let newPack: PackBase? = createInstance(data)
        
        if nil == newPack {
            packBaseTmp = nil
        } else {
            packList.append(newPack!)
            packBaseTmp = packList[0]
            
        }
        
        packListLock.unlock()
        
        return packBaseTmp
    }
    
    class func clearPacks() {
        packSendListLock.lock()
        packSendList.removeAll()
        packSendListLock.unlock()
        packListLock.lock()
        packList.removeAll()
        packListLock.unlock()
    }
}
