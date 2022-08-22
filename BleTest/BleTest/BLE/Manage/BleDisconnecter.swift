//
//  BleDisconnecter.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

// MARK: 断开连接
class BleDisconnecter: BleDoInterface {
    
    init() {
        clear()
    }
    
    func bleDo() -> BleState {
        Logger.debug("IsdtDisconnecter")
        var bleStateRet = BleState.DISCONN
        
        kBleMessage.disconnectDevice()
        
        if BleMessage.BLE_DO_OUTER_IDLE == kBleMessage.bleDoOuter {
            bleStateRet = BleState.IDLE
            kBleMessage.bleDoOuter = 0
            
        } else {
            kBleMessage.startComm()
        }
        return bleStateRet
    }
    
    func clear() {
        // let logger = Logger.shared
        // logger.d("IsdtDisconnecter: clear")
    }
}
