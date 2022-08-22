//
//  BleVersionQuerier.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class BleVersionQuerier: BleDoInterface {
    
    var querying:Bool = false
    var queried:Bool = false
    var packBaseRead:PackBase? = nil
    var outTime = 0
    
    func bleDo() -> BleState {
        Logger.debug("IsdtVersionQuerier")
        var bleStateRet = BleState.QUERY_VERSION
                
        if !kBleMessage.bootState {
            
            if !querying {
                querying = true
                let hardwareInformationQuery = HardwareInformationReq()
                let packSendTmp = PackBase.assemblePackSend(packBase: hardwareInformationQuery)
                kBleMessage.currentDeviceScan?.packSend = packSendTmp
                kBleMessage.currentDeviceScan?.doPackSend(packSend: packSendTmp)
            }
            
            if queried {
                kBleMessage.startTime = Date().secondTime
                
                bleStateRet = BleState.COMMUNICATION
            }
        }else {
            //                mBleMessage.bleCommunicater.communicated = true
            bleStateRet = BleState.COMMUNICATION
            kBleMessage.startTime = Date().secondTime
        }
        
        outTime = Date().secondTime - kBleMessage.startTime
        if outTime > 10 {
            bleStateRet = BleState.DISCONN
        }
        
        return bleStateRet
    }
    
    func clear() {
        // let logger = Logger.shared
        // logger.d("IsdtVersionQuerier: clear")
        querying = false
        queried = false
        packBaseRead = nil
        outTime = 0
    }
}
