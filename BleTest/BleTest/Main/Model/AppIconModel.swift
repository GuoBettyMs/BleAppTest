//
//  AppIconModel.swift
//  IOSApp
//
//  Created by gbt on 2022/4/21.
//

import Foundation
import CoreBluetooth

struct AppIconModel {
    
    var visitime: String
    var detail: String
    var searchtime: String
    var product: ProductType
    
    var type: String
    var titlename: String
    var identifier: String
    var peripheral: CBPeripheral?
    var broadcastPacketAnalysis: BroadcastPacketAnalysis
    var scanPacketAnalysis: ScanPacketAnalysis
    var offlineBool = false
    

    init(type: String, titlename: String, identifier: String, peripheral: CBPeripheral?, product: ProductType, broadcastPacketAnalysis: BroadcastPacketAnalysis, scanPacketAnalysis: ScanPacketAnalysis, offlineBool: Bool, visitime: String, detail: String, searchtime: String) {
        
        self.titlename = titlename
        self.visitime = visitime
        self.detail = detail
        self.searchtime = searchtime
        self.product = product
        self.type = type
        self.peripheral = peripheral
        self.identifier = identifier
        self.broadcastPacketAnalysis = broadcastPacketAnalysis
        self.offlineBool = offlineBool
        self.scanPacketAnalysis = scanPacketAnalysis
        
    }
    

    
}
