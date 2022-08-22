//
//  MyBluetoothDevice.swift
//  IOSApp
//
//  Created by gbt on 2022/5/9.
//

import Foundation
import CoreBluetooth

class MyBluetoothDevice{
    
    var identifier: String
    var lastUsed:Bool
    var peripheral : CBPeripheral?
    
    var characteristicAF01: CBCharacteristic? = nil
    var characteristicAF02: CBCharacteristic? = nil
    var characteristicFEE1: CBCharacteristic? = nil
    var peripheralFEE1: CBPeripheral? = nil
    
    var packSend:PackSend?
    
    init(cBPeripheral: CBPeripheral) {
        peripheral = cBPeripheral
        identifier = peripheral!.identifier.uuidString
        lastUsed = true
    }
    
    func doPackSend(packSend: PackSend?) {
        if let sendContent = packSend?.sendContent {
            let data = Data.init(sendContent)
                        var s = ""
                        for i in 0..<sendContent.count {
                            s += String(format: "%02x ", sendContent[i])
                        }
                        Logger.debug("start write: " + s)
            if characteristicAF02 != nil{
                //Logger.debug("start write AF02characteristic: \(String(describing: characteristicAF02))")
                peripheral?.writeValue(data, for: characteristicAF02!, type: .withResponse)
            }
            
        }
    }
    
    func writeAF01(packSend: PackSend?){
        if let sendContent = packSend?.sendContent {
            let data = Data.init(sendContent)
                        var s = ""
                        for i in 0..<sendContent.count {
                            s += String(format: "%02x ", sendContent[i])
                        }
                        Logger.debug("start write: " + s)
            if characteristicAF01 != nil && data[0] != 0x18{
                //Logger.debug("start write AF01characteristic: \(String(describing: characteristicAF01))")
                peripheral?.writeValue(data, for: characteristicAF01!, type: .withResponse)
            }
        }
    }
    
    //BleMessage.swift(177)
    func writeUpdateData(updateData: [UInt8]){
        if characteristicFEE1 != nil {
            let data = Data.init(updateData)
            var s = ""
            for i in 0..<updateData.count {
                s += String(format: "%02x ", updateData[i])
            }
            Logger.debug("start writeFEE1: " + s)
            //Logger.debug("BA11characteristic: \(String(describing: characteristicFEE1))")
            peripheral?.writeValue(data, for: characteristicFEE1!, type: .withResponse)
        }
    }
    
    
}
