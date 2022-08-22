//
//  BleBinder.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

// MARK: 绑定设备
class BleBinder: BleDoInterface {
    
    var binding:Bool = false
    var bound:Bool = false
    var boundInfoChanged:Bool = false
    private var outTime = 0
    var fastBinding = false
    
    init() {
        clear()
    }
    
    func bleDo() -> BleState {
        Logger.debug("BleBinder")
        var bleStateRet = BleState.BIND
        
        Logger.debug("binding: \(binding)")
        if !binding && kBleMessage.currentDeviceScan != nil{
            binding = true
            let bindingRequest = BindingRequest()
            bindingRequest.uuid = kBleMessage.currentDeviceScan!.identifier
            if fastBinding {
                bindingRequest.fastBinding = 1
            }
            let packSendTmp = PackBase.assemblePackSend(packBase: bindingRequest)
            kBleMessage.currentDeviceScan?.packSend = packSendTmp
            kBleMessage.currentDeviceScan?.doPackSend(packSend: packSendTmp)
            
        }
        
        if bound {
            bleStateRet = BleState.QUERY_VERSION
        } else if boundInfoChanged {
            bleStateRet = BleState.BIND_INFO_CHANGED
        }
        
        
        outTime = Date().secondTime - kBleMessage.startTime
        if outTime > 30 {
            bleStateRet = BleState.DISCONN
            binding = false
        }
        
        return bleStateRet
    }
    
    func clear() {
        Logger.debug("BleBinder: clear")
        binding = false
        bound = false
        boundInfoChanged = false
        outTime = 0
        fastBinding = false
    }
}
