//
//  BleIdler.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import Foundation

class BleIdler: BleDoInterface {
    
    init() {
        clear()
    }
    
    func bleDo() -> BleState {
//        Logger.debug("IsdtIdler")
        let isdtBleStateRet = BleState.IDLE
        
        return isdtBleStateRet
    }
    
    func clear() {
        // let logger = Logger.shared
        // logger.d("IsdtIdler: clear")
    }
}
