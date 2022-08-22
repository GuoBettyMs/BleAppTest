//
//  BleScanner.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation
import CoreBluetooth

// MARK: 自动断开连接重新扫描设备
class BleScanner: BleDoInterface {
    
    var scanning:Bool = false
    var found:Bool = false
    var identifier:String = ""
    var outTime = 0
    var peripheral: CBPeripheral? = nil
    
    func bleDo() -> BleState {
        Logger.debug("BleScanner")
        var bleStateRet = BleState.SCAN
        
        if !scanning {
            found = false
            scanning = true
            identifier = kBleMessage.currentDeviceScan?.identifier ?? ""
            if kBleMessage.btAvailable {
//                kBleMessage.startScanDeviceCurrentDevice()
                kBleMessage.startScanDeviceData()
            }
        }
        
        if found {
            kBleMessage.startTime = Date().secondTime
            bleStateRet = BleState.CONNECT
            
        }
        
        outTime = Date().secondTime - kBleMessage.startTime
        if outTime > 15 {
            bleStateRet = BleState.DISCONN
        }
        
        return bleStateRet
    }
    
    func clear() {
        kBleMessage.stopScanDevice()
        scanning = false
        found = false
        identifier = ""
        peripheral = nil
        outTime = 0
    }
    
}
