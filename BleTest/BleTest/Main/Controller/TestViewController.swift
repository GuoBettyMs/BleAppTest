//
//  TestViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/4/24.
//

import UIKit
import CoreBluetooth

class TestViewController: UIViewController {

    @IBOutlet weak var testtableView: TesttableView!
    var scanDbModelList = [AppIconModel]()
    let mBleMessage = BleMessage.sharedInstance

    let scanDbManager = ScanDbManager()
    var databaseList: [AppIconModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mBleMessage.startScanDeviceData()
        testtableView.testViewController = self
        
//        mBleMessage.scanDeviceTypealias = nil
        
        databaseList = scanDbManager.query()

        var startTime = Date().milliTime

        mBleMessage.scanDeviceTypealias = { [self]
            (_ peripheral: CBPeripheral, _ broadcastPacketAnalysis: BroadcastPacketAnalysis, _ scanPacketAnalysis: ScanPacketAnalysis)->() in
            
            //判断数据库里是否存在
            for item in databaseList! {
                if item.identifier == peripheral.identifier.uuidString {
                    return
                }
            }
            
            
            let time = Date().milliTime
            Logger.debug("namename=\(broadcastPacketAnalysis.name)  identifier=\(peripheral.identifier.uuidString)")
            Logger.debug("testtableView.scanCellsModelList.count= \(testtableView.scanCellsModelList.count)")
            
            var addBool = false
            for item in testtableView.scanCellsModelList {
                if item.peripheral == peripheral {
                    addBool = false
                    if testtableView.scanCellsModelList.count > 2 {
                        for i in 0..<testtableView.scanCellsModelList.count {
                            if testtableView.scanCellsModelList[i].peripheral == peripheral {
                                testtableView.scanCellsModelList[i].broadcastPacketAnalysis = broadcastPacketAnalysis
                            }
                        }
                        
                        for _ in 0..<testtableView.scanCellsModelList.count - 1 {
                            for j in 0..<testtableView.scanCellsModelList.count - 1 {
                                if Int(truncating: testtableView.scanCellsModelList[j].broadcastPacketAnalysis.rssi)+12 < Int(truncating: testtableView.scanCellsModelList[j+1].broadcastPacketAnalysis.rssi) {
                                    testtableView.scanCellsModelList.rearrange(from: j+1,to: j)
                                }
                            }
                        }

                        if (time - startTime) > 300 {
                            Logger.debug("时间: \(time)")
                            startTime = Date().milliTime
                            testtableView.tabView.reloadData()
                        }
                        
                    }
                    
                    return
                    
                }else {
                    addBool = true
                }
            }
            
            
//            if (time - startTime) > 200 {
////                Logger.debug("时间", "\(time)")
//                startTime = Date().milliTime
//                for scanDbModel in scanDbModelList {
//                    if scanDbModel.peripheral == peripheral {
//                        return
//                    }
//                }
//                Logger.debug("namename=\(broadcastPacketAnalysis.name)  identifier=\(peripheral.identifier.uuidString)")
//                for item in databaseList {
//                    if item.identifier == peripheral.identifier.uuidString {
//                        return
//                    }
//                }
            
            if addBool || testtableView.scanCellsModelList.count == 0 {
            
                let productType = Product.types(broadcastPacketAnalysis.deviceModelID)
                if productType != ProductType.Null {

                    let scanData = AppIconModel(type: broadcastPacketAnalysis.deviceModelID, titlename: broadcastPacketAnalysis.name, identifier: peripheral.identifier.uuidString, peripheral: peripheral, product: productType, broadcastPacketAnalysis: broadcastPacketAnalysis, scanPacketAnalysis: scanPacketAnalysis, offlineBool: false, visitime: "", detail: "", searchtime: "")
//                    Logger.debug("peripheral= \(scanData.peripheral)")
                   
                    scanDbModelList.append(scanData)
                    testtableView.scanCellsModelList.append(scanData)

//                    testtableView.tabView.beginUpdates()
//                    testtableView.tabView.insertRows(at: [IndexPath(row: scanDbModelList.count-1, section: 0)], with: .none)
//                    testtableView.tabView.endUpdates()
                    
                    if (time - startTime) > 300 {
                        Logger.debug("时间: \(time)")
                        startTime = Date().milliTime
                        testtableView.tabView.reloadData()
                    }
                }
            }
        }
        
//        let scanData1 = AppIconModel(type: "Calculator", titlename: NSLocalizedString("Calculator", comment: "Calculator"), identifier: "nil", peripheral: nil, product: Product.types("Calculator"), broadcastPacketAnalysis: BroadcastPacketAnalysis.init(bytes: nil), scanPacketAnalysis: ScanPacketAnalysis.init(dataString: ""), visitime: "00:00:03", detail: "00:00:03", searchtime: "00:00:03")
//        scanDbModelList.append(scanData1)
//        testtableView.scanCellsModelList.append(scanData1)
//        testtableView.tabView.insertRows(at: [IndexPath(row: scanDbModelList.count-1, section: 0)], with: .none)


        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        mBleMessage.startScanDeviceData()
        
    }
    
    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
 

}
