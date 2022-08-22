//
//  BleConnecter.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

enum BleState {
    case IDLE
    case SCAN
    case CONNECT
    case BIND
    case QUERY_VERSION
    case COMMUNICATION
    case DISCONN
    
    /* error state */
    case BIND_INFO_CHANGED
}

protocol BleDoInterface {
    func bleDo() -> BleState
    func clear()
    
}

// MARK: 连接设备
class BleConnecter: BleDoInterface {
    
    var connecting:Bool = false
    var connected:Bool = false
    var connectState:Int = 0
    private var outTime = 0
    
    init() {
        clear()
    }
    
    func bleDo() -> BleState {
        Logger.debug("BleConnecter")
        var bleStateRet = BleState.CONNECT
        
        if !connecting {
            connecting = true
            if nil != kBleMessage.currentDeviceScan?.peripheral {
                kBleMessage.connectDevice(device: kBleMessage.currentDeviceScan!.peripheral!)
            }
        }
        
        if connected {
            bleStateRet = BleState.BIND
            // IsdtBinder.setGatt(IsdtBinder)
        }
        
        //外设蓝牙连接超出15s ，断开设备
        outTime = Date().secondTime - kBleMessage.startTime
        if outTime > 15 {
            Logger.debug("outTimeoutTimeoutTimeoutTimeoutTimeoutTimeoutTime")

            bleStateRet = BleState.DISCONN
        }
        
        return bleStateRet
    }
    
    func clear() {
        Logger.debug("BleConnecter: clear")
        connecting = false
        connected = false
        outTime = 0
    }
}
