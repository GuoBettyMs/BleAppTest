//
//  UpgradeHandle.swift
//  IOSApp
//
//  Created by gbt on 2022/5/12.
//

import Foundation
import UIKit
import AudioToolbox

class UpgradeHandle {
    
    static func upgradeHandle(firmwareAnalysis: FirmwareAnalysis, name: String, connectionStatus: Bool) {
        
        let content = UNMutableNotificationContent()
        let settings = Settings.sharedInstance
        var dispatchWorkItem: DispatchWorkItem?
        var writeBuf: [UInt8] = []
        let milliseconds = DispatchTimeInterval.milliseconds(60)
        let updateAlertView = UpdateAlertView.init(frame: CGRect.init(x: 0, y: 0, width: firmwareAnalysis.firmwareAnalysisViewController!.view.frame.width, height:  firmwareAnalysis.firmwareAnalysisViewController!.view.frame.height))
        updateAlertView.percentageL.text = "0%"
        firmwareAnalysis.firmwareAnalysisViewController?.view.addSubview(updateAlertView)
       
        
        let mBleMessage = BleMessage.sharedInstance
        var packBaseReadList:[PackBase] = []

        PackBase.clearPacks()
        
        if !connectionStatus {
            mBleMessage.setCurrentDevice(currentDeviceScan: firmwareAnalysis.myDevice)
            mBleMessage.startCommConn()
        }
        
        firmwareAnalysis.firmwareUpgradeErrorTimes = 0
        
        dispatchWorkItem = DispatchWorkItem {
            
            Logger.debug("\(firmwareAnalysis.firmwareUpgradeErrorTimes)")
            
            let packBaseTmp = mBleMessage.getNextPack()
            let start = mBleMessage.bleDo(packBaseWrite: packBaseTmp, packBaseReadList: &packBaseReadList)
            
            if firmwareAnalysis.firmwareUpgradeErrorTimes > firmwareAnalysis.FIRMWARE_UPGRADE_MAX_ERROR_TIMES {
                Logger.debug("upgrade: timeout")
                firmwareAnalysis.upgradeState = FirmwareUpgradeState.TIMEOUT
            }
            
            switch (firmwareAnalysis.upgradeState) {
            case .CONNECT:
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                mBleMessage.clearPackCmdList()
                if start == BleState.COMMUNICATION {
                    firmwareAnalysis.upgradeState = .UPGRADE
                    let oTAUpgradeCmdReq = OTAUpgradeCmdReq()
                    mBleMessage.putPackBaseUserList(packBase: oTAUpgradeCmdReq)
                    firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                    Logger.debug("start write:UPGRADE")
                }

            case .UPGRADE:
                
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if packBaseReadList.count > 0 {
                if let packBase = packBaseReadList[0] as? OTAUpgradeCmdResp {
                    if packBase.state {
                        
                        mBleMessage.disconnectDevice()
                        mBleMessage.startCommConn()
                        firmwareAnalysis.upgradeState = .RECONNECT
                        firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                    } else {
                        firmwareAnalysis.upgradeState = .ERROR
                    }
                }
                }
            case .RECONNECT:
                
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if start == BleState.COMMUNICATION {
                    let oTAEraseReq = OTAEraseReq()
                    oTAEraseReq.startAddress = firmwareAnalysis.appStorageOffset
                    oTAEraseReq.size = firmwareAnalysis.appSize
                    mBleMessage.putPackBaseUserList(packBase: oTAEraseReq)
                    firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                    firmwareAnalysis.upgradeState = .ERASE
                }

            case .ERASE:
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if packBaseReadList.count > 0 {
                if let packBase = packBaseReadList[0] as? OTAEraseResp {
                    if packBase.state {

                        Thread.sleep(forTimeInterval: 4)
                            mBleMessage.upgradeBool = true
                        writeBuf.removeAll()
                            for i in 0..<128 {
                                writeBuf.append(firmwareAnalysis.firmwareData[Int(firmwareAnalysis.sizeWritten) + i])
                            }
                            let oTAWriteReq = OTAWriteReq()
                            oTAWriteReq.startAddress = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                            Logger.debug("add: \(oTAWriteReq.startAddress)   size: " + "\(firmwareAnalysis.sizeWritten)   appStorageOffset: \(firmwareAnalysis.appStorageOffset)")
                            oTAWriteReq.data = writeBuf

                            let pack = PackBase.assemblePackSend(packBase: oTAWriteReq)
                            mBleMessage.currentDeviceScan?.packSend = pack
                            mBleMessage.currentDeviceScan?.doPackSend(packSend: pack)
                            firmwareAnalysis.upgradeState = .WRITE
                            firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                            firmwareAnalysis.FIRMWARE_UPGRADE_MAX_ERROR_TIMES = 18400
                            
//                        })
                    }else {
                        firmwareAnalysis.upgradeState = .ERROR
                    }
                }

                }
            case .WRITE:

                Logger.debug("upgrade: WRITE")
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if packBaseReadList.count > 0{
                    if let packBase = packBaseReadList[0] as? OTAWriteResp {
                        packBaseReadList.removeAll()
                        if packBase.state == 0 {
                            
                            let size = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                            Logger.debug("add:\(packBase.statAddress) + written: \(size)")
                            
                            if packBase.statAddress == size {
                                
                                firmwareAnalysis.sizeWritten += 128
                                
                                let percentage = (firmwareAnalysis.sizeWritten * 100) / UInt32(firmwareAnalysis.firmwareData.count)
                                
                                updateAlertView.percentageL.text = "\(percentage)%"
                                updateAlertView.updateCircleArcView.setProgress(Int(percentage))
                                
                                
                                if firmwareAnalysis.sizeWritten >= firmwareAnalysis.firmwareData.count {
                                    mBleMessage.upgradeBool = false
                                    let firmwareDataBlockNum = firmwareAnalysis.firmwareData.count / 4
                                    var checksum:UInt64 = 0
                                    var longTmp:UInt64 = 0
                                    var tmp = 0
                                    for i in 0..<firmwareDataBlockNum {
                                        longTmp = 0
                                        
                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 3] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8
                                        
                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 2] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8
                                        
                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 1] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8
                                        
                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 0] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        
                                        checksum += longTmp
                                    }
                                    let oTAChecksumReq = OTAChecksumReq()
                                    oTAChecksumReq.appChecksum = UInt32(checksum & 0xFFFFFFFF)
                                    oTAChecksumReq.size = UInt32(firmwareDataBlockNum * 4)
                                    oTAChecksumReq.startAddress = firmwareAnalysis.appStorageOffset
                                    mBleMessage.putPackBaseUserList(packBase: oTAChecksumReq)
                                   
                                    firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                                    firmwareAnalysis.upgradeState = .VERIFY
                                }else {
                                    
                                    let size = Int(firmwareAnalysis.sizeWritten)
                                    Logger.debug("add:size: " + "\(size)")
                                    writeBuf.removeAll()
                                    for i in 0..<128 {
                                        let j = size + i
                                        writeBuf.append(firmwareAnalysis.firmwareData[j])
                                    }
                                    let oTAWriteReq = OTAWriteReq()
                                    oTAWriteReq.startAddress = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                                    Logger.debug("add: \(oTAWriteReq.startAddress)   size: " + "\(firmwareAnalysis.sizeWritten)")
                                    //Logger.debug("statAddresswritten:\(oTAWriteReq.startAddress)")
                                    oTAWriteReq.data = writeBuf
                                    //mBleMessage.putPackBaseUserList(packBase: oTAWriteReq)
                                    
                                    let pack = PackBase.assemblePackSend(packBase: oTAWriteReq)
                                    mBleMessage.currentDeviceScan?.packSend = pack
                                    mBleMessage.currentDeviceScan?.doPackSend(packSend: pack)
                                    
                                }
                            }else {
                                
                                //firmwareAnalysis.upgradeState = .ERROR
                                
                            }
                        }else if packBase.state == 254 || packBase.state == 253 {

                            if packBase.statAddress == 0 {
                                firmwareAnalysis.sizeWritten = 0
                                writeBuf.removeAll()
                                    for i in 0..<128 {
                                        writeBuf.append(firmwareAnalysis.firmwareData[Int(firmwareAnalysis.sizeWritten) + i])
                                    }
                                    let oTAWriteReq = OTAWriteReq()
                                    
                                    oTAWriteReq.startAddress = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                                    Logger.debug("add: \(oTAWriteReq.startAddress)   size: " + "\(firmwareAnalysis.sizeWritten)   appStorageOffset: \(firmwareAnalysis.appStorageOffset)")
                                    oTAWriteReq.data = writeBuf
                                    //mBleMessage.putPackBaseUserList(packBase: oTAWriteReq)
                                    let pack = PackBase.assemblePackSend(packBase: oTAWriteReq)
                                    mBleMessage.currentDeviceScan?.packSend = pack
                                    mBleMessage.currentDeviceScan?.doPackSend(packSend: pack)
                            } else {
                                firmwareAnalysis.sizeWritten = packBase.statAddress - firmwareAnalysis.appStorageOffset
                            }
                        
                        mBleMessage.bleCommunicater.clear()


                            let size = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                            Logger.debug("statAddress:\(packBase.statAddress) + written: \(size)")

                            if packBase.statAddress == size {

                                firmwareAnalysis.sizeWritten += 128

                                let percentage = (firmwareAnalysis.sizeWritten * 100) / UInt32(firmwareAnalysis.firmwareData.count)

                                updateAlertView.percentageL.text = "\(percentage)%"
                                updateAlertView.updateCircleArcView.setProgress(Int(percentage))


                                if firmwareAnalysis.sizeWritten >= firmwareAnalysis.firmwareData.count {
                                    //mBleMessage.upgradeBool = false
                                    let firmwareDataBlockNum = firmwareAnalysis.firmwareData.count / 4
                                    var checksum:UInt64 = 0
                                    var longTmp:UInt64 = 0
                                    var tmp = 0
                                    for i in 0..<firmwareDataBlockNum {
                                        longTmp = 0

                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 3] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8

                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 2] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8

                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 1] & 0xFF)
                                        longTmp += UInt64(tmp)
                                        longTmp <<= 8

                                        tmp = Int(firmwareAnalysis.firmwareData[i * 4 + 0] & 0xFF)
                                        longTmp += UInt64(tmp)

                                        checksum += longTmp
                                    }
                                    let oTAChecksumReq = OTAChecksumReq()
                                    oTAChecksumReq.appChecksum = UInt32(checksum & 0xFFFFFFFF)
                                    oTAChecksumReq.size = UInt32(firmwareDataBlockNum * 4)
                                    oTAChecksumReq.startAddress = firmwareAnalysis.appStorageOffset
                                    mBleMessage.putPackBaseUserList(packBase: oTAChecksumReq)

                                    firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                                    firmwareAnalysis.upgradeState = .VERIFY
                                }else {
                                    var writeBuf: [UInt8] = []
                                    for i in 0..<128 {
                                        writeBuf.append(firmwareAnalysis.firmwareData[Int(firmwareAnalysis.sizeWritten) + i])
                                    }
                                    let oTAWriteReq = OTAWriteReq()
                                    oTAWriteReq.startAddress = firmwareAnalysis.appStorageOffset + firmwareAnalysis.sizeWritten
                                    Logger.debug("add1111111: \(oTAWriteReq.startAddress)   size: " + "\(firmwareAnalysis.sizeWritten)")
                                    //Logger.debug("statAddresswritten:\(oTAWriteReq.startAddress)")
                                    oTAWriteReq.data = writeBuf
                                    //                                mBleMessage.putPackBaseUserList(packBase: oTAWriteReq)

                                    let pack = PackBase.assemblePackSend(packBase: oTAWriteReq)
                                    mBleMessage.currentDeviceScan?.packSend = pack
                                    mBleMessage.currentDeviceScan?.doPackSend(packSend: pack)

                                }

                            }

                        }
                    }
                }
                
            case .VERIFY:
                
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if packBaseReadList.count > 0 {

                        if let packBase = packBaseReadList[0] as? OTAChecksumResp {
                            if packBase.state {
                                firmwareAnalysis.firmwareUpgradeErrorTimes = 0
     
                                let oTARebootReq = OTARebootReq()
                                mBleMessage.putPackBaseUserList(packBase: oTARebootReq)
                                firmwareAnalysis.upgradeState = .REBOOT
                            } else {
                                firmwareAnalysis.upgradeState = .ERROR
                            }
                        }
                                    
                }
            case .REBOOT:
                firmwareAnalysis.firmwareUpgradeErrorTimes += 1
                if packBaseReadList[0] is OTARebootResp {
                    firmwareAnalysis.upgradeState = .SUCCESS
                }

            case .SUCCESS:
                break
            case .TIMEOUT:
                firmwareAnalysis.upgradeState = .ERROR

            case .ERROR:
                firmwareAnalysis.upgradeState = .ERROR

            }
            if FirmwareUpgradeState.TIMEOUT != firmwareAnalysis.upgradeState && FirmwareUpgradeState.ERROR != firmwareAnalysis.upgradeState &&
                FirmwareUpgradeState.SUCCESS != firmwareAnalysis.upgradeState{
                DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + milliseconds, execute: dispatchWorkItem!)
            } else {
                content.title = name
                updateAlertView.removeFromSuperview()
                mBleMessage.disconnectDevice()
                
                if connectionStatus {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reconnectThread"), object: false)
                    
                }else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: false)
                }
                
                if FirmwareUpgradeState.TIMEOUT == firmwareAnalysis.upgradeState {
                    
                    updateAlertView.removeFromSuperview()
                    
                    Alert.alert(title: NSLocalizedString("UpgradeTimeout", comment: "UpgradeTimeout"), controllerV: firmwareAnalysis.firmwareAnalysisViewController!)
                    mBleMessage.disconnectDevice()
                    
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " +  NSLocalizedString("UpgradeTimeout", comment: "UpgradeTimeout")
                    
                } else if FirmwareUpgradeState.ERROR == firmwareAnalysis.upgradeState {
                    
                    updateAlertView.removeFromSuperview()
                    Alert.alert(title: NSLocalizedString("UpgradeFailed", comment: "UpgradeFailed"), controllerV: firmwareAnalysis.firmwareAnalysisViewController!)
                    mBleMessage.disconnectDevice()
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " +  NSLocalizedString("UpgradeFailed", comment: "UpgradeFailed")

                } else if FirmwareUpgradeState.SUCCESS == firmwareAnalysis.upgradeState {
                    
                    updateAlertView.removeFromSuperview()
                    
                    Alert.alert(title: NSLocalizedString("UpgradeSuccessed", comment: "UpgradeSuccessed"), controllerV: firmwareAnalysis.firmwareAnalysisViewController!)
                    mBleMessage.disconnectDevice()
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " + NSLocalizedString("UpgradeSuccessed", comment: "UpgradeSuccessed")

                }
                
                content.userInfo = ["userName": "isdt", "articleId": 11]
                if settings.shockBool {
                    let soundMiddle = SystemSoundID(1519)
                    AudioServicesPlaySystemSound(soundMiddle)
                }
                if settings.beepBool {
                    
                    var soundID:SystemSoundID = 0
                    //获取声音地址
                    let path = Bundle.main.path(forResource: "beep", ofType: "mp3")
                    //地址转换
                    let baseURL = NSURL(fileURLWithPath: path!)
                    //赋值
                    AudioServicesCreateSystemSoundID(baseURL, &soundID)
                    AudioServicesPlaySystemSound (soundID)
                }
                
                //设置通知触发器
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                //设置请求标识符
                let requestIdentifier = "testNotification"
                
                //设置一个通知请求
                let request = UNNotificationRequest(identifier: requestIdentifier,
                                                    content: content, trigger: trigger)
                
                //将通知请求添加到发送中心
                UNUserNotificationCenter.current().add(request) { error in
                    if error == nil {
                        print("Time Interval Notification scheduled: \(requestIdentifier)")
                    }
                }
                //删除全部已发送通知
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                dispatchWorkItem?.cancel()
                dispatchWorkItem = nil
            }
        }
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + milliseconds, execute: dispatchWorkItem!)
    }
    
    
}
