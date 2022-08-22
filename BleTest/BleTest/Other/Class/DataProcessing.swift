//
//  DataProcessing.swift
//  ISD Link
//
//  Created by isdt on 2021/7/22.
//

import Foundation
import CoreBluetooth


class DataProcessing {
    
    //MARK: 对比数据
    static func comparedData(scanDbModelList: [AppIconModel], comparedScanModelList: [AppIconModel], i: Int) -> [AppIconModel] {
        var newComparedScanModelList = comparedScanModelList
        if newComparedScanModelList.count == 0 {
            newComparedScanModelList.append(scanDbModelList[i])
        }else {
            var addBool = false
            for compared in comparedScanModelList {
                if scanDbModelList[i].identifier == compared.identifier {
                    break
                }else {
                    addBool = true
                }
            }
            if addBool {
                newComparedScanModelList.append(scanDbModelList[i])
            }
        }
        return newComparedScanModelList
    }
    
    //MARK: 在线
    static func lineData(scanDbModelList: [AppIconModel], lineScanModelList: [AppIconModel], i: Int, peripheral: CBPeripheral, broadcastPacketAnalysis: BroadcastPacketAnalysis) -> [AppIconModel] {
        var newLineScanModelList = lineScanModelList
        if lineScanModelList.count == 0 {
            newLineScanModelList.append(scanDbModelList[i])
        }else {
            var addBool = false
            for compared in lineScanModelList {
                if scanDbModelList[i].identifier == compared.identifier {
                    break
                }else {
                    addBool = true
                }
            }
            if addBool {
                newLineScanModelList.append(scanDbModelList[i])
            }
        }
        
        var j = 0
        while j < newLineScanModelList.count {
            if newLineScanModelList[j].identifier == peripheral.identifier.uuidString {
                newLineScanModelList[j].broadcastPacketAnalysis = broadcastPacketAnalysis
                newLineScanModelList[j].offlineBool = true
                newLineScanModelList[j].peripheral = peripheral
                break
            }
            j += 1
        }
        return newLineScanModelList
    }
    
    static func sortName(modelList: [AppIconModel]) -> [AppIconModel] {
        
        var sortNameLsit: [AppIconModel] = []
        
        for model in modelList {
            if model.type == "01010000" || model.type == "81010000" {
                sortNameLsit.append(model)
            }
        }
        
        for model in modelList {
            if model.type == "01020000" || model.type == "81020000" {
                sortNameLsit.append(model)
            }
        }
        
        
        return sortNameLsit
    }
    
    
}
