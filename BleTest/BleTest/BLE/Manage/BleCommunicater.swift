//
//  BleCommunicater.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

// MARK: 连接通信发送
class BleCommunicater: BleDoInterface {
    
    var communicating:Bool = false
    var communicated:Bool = false
    var packBaseWrite:PackBase? = nil
    var packBaseRead:PackBase? = nil
    var upgradeBool: Bool = false
    var outTime = 0
    
    init() {
        clear()
    }
    
    func bleDo() -> BleState {
        //Logger.debug("Communicater")
        var bleStateRet = BleState.COMMUNICATION
        
        if kBleMessage.upgradeBool {
            communicated = true
        }
        
        if communicated {
            outTime = 0
            kBleMessage.startTime = Date().secondTime
            communicating = false
            communicated = false
        }
        
        Logger.debug("Communicater: \(communicating)")
        if !communicating && !kBleMessage.upgradeBool {
            if nil != packBaseWrite {
                communicating = true
                let packSendTmp = PackBase.assemblePackSend(packBase: packBaseWrite)
                kBleMessage.currentDeviceScan?.packSend = packSendTmp
                kBleMessage.currentDeviceScan?.writeAF01(packSend: packSendTmp)
                
            }
        }
        //Logger.debug("start Communicater: \(communicated)")
        
        outTime = Date().secondTime - kBleMessage.startTime
        
        if outTime > 3 {
            communicating = false
            communicated = true
        }
        
        if outTime > 10 || !kBleMessage.isConnection {
            bleStateRet = BleState.DISCONN
        }
        
        return bleStateRet
    }
    
    func clear() {
        //Logger.debug("Communicater: clear")
        
        communicating = false
        communicated = false
        packBaseRead = nil
        packBaseWrite = nil
        outTime = 0
    }
}
