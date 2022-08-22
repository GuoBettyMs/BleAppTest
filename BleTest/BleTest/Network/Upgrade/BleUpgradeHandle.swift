//
//  BleUpgradeHandle.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation
import UIKit
import AudioToolbox

class BleUpgradeHandle {
    
    static func upgradeHandle(firmwareAnalysis: BleFirmwareAnalysis, name: String, internalBool: Bool) {
        
        var checksumBool = false
        let content = UNMutableNotificationContent()
        let settings = Settings.sharedInstance
        var dispatchWorkItem: DispatchWorkItem?
        let milliseconds = DispatchTimeInterval.milliseconds(60)
        var percentage: Float = 0
        let updateAlertView = UpdateAlertView.init(frame: CGRect.init(x: 0, y: 0, width: firmwareAnalysis.bleFirmwareAnalysisViewController!.view.frame.width, height:  firmwareAnalysis.bleFirmwareAnalysisViewController!.view.frame.height))
        updateAlertView.percentageL.text = "0%"
        firmwareAnalysis.bleFirmwareAnalysisViewController?.view.addSubview(updateAlertView)
        let mBleMessage = BleMessage.sharedInstance
        
        //        PackBase.clearPacks()
        //        mBleMessage.setCurrentDevice(currentDeviceScan: firmwareAnalysis.myDevice)
        //        mBleMessage.otaCommConn()
        mBleMessage.otaUpate = false
        //mBleMessage.bleCommunicater.upgradeBool = true
        var packBaseReadList:[PackBase] = []
        firmwareAnalysis.firmwareUpgradeErrorTimes = 0
        var reaseBool = false
        var endBool = false
        var offset = 0
        
        var oneBool = false
        var startTime = Date().secondTime
        var endTime = 0
        
        var timeOut = 20
        
        dispatchWorkItem = DispatchWorkItem {
            
            //Logger.debug("时间： \(firmwareAnalysis.firmwareUpgradeErrorTimes)")
            
            let packBaseTmp = mBleMessage.getNextPack()
            let startBleMessage = mBleMessage.bleDo(packBaseWrite: packBaseTmp, packBaseReadList: &packBaseReadList)
            
            
            if endTime > timeOut {
                Logger.debug("upgrade: timeout")
                firmwareAnalysis.upgradeState = BleUpgradeState.TIMEOUT
            }
            
            Logger.debug("状态： ", "\(firmwareAnalysis.upgradeState)")
            
            switch (firmwareAnalysis.upgradeState) {
                
            case .CONNECT:
                
                if mBleMessage.bootState {
                    if !oneBool {
                        mBleMessage.upgradeBool = true
                        oneBool = true
                        mBleMessage.disconnectDevice()
                        firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                        startTime = Date().secondTime
                        endTime = 0
                    }else {
                        if endTime > 4 {
                            mBleMessage.bleConnecter.connecting = false
                            mBleMessage.setCurrentDevice(currentDeviceScan: firmwareAnalysis.myDevice)
                            mBleMessage.startCommConn()
                            startTime = Date().secondTime
                            endTime = 0
                            firmwareAnalysis.upgradeState = .UPGRADE
                        }
                    }
                }
                
            case .UPGRADE:
                
                if startBleMessage == .COMMUNICATION {
                    mBleMessage.upgradeBool = true
                    mBleMessage.bootInfoModel.clear()
                    let info = [0x84,UInt8(18)]
                    mBleMessage.Updatewrite(data: info)
                    startTime = Date().secondTime
                    endTime = 0
                    firmwareAnalysis.upgradeState = .RECONNECT
                    
                }
                
            case .RECONNECT:
                
                if mBleMessage.bootInfoModel.offset > 100 {
                    firmwareAnalysis.upgradeState = .ERASE
                    startTime = Date().secondTime
                    endTime = 0
                    
                }
            case .ERASE:
                
                
                if !reaseBool {
                    reaseBool = true
                    let writeOTAData = firmwareAnalysis.eraseCommand()
                    mBleMessage.Updatewrite(data: writeOTAData)
//                    Thread.sleep(forTimeInterval: 3.5)
                }
                mBleMessage.currentDeviceScan!.peripheral!.readValue(for: (mBleMessage.currentDeviceScan?.characteristicFEE1)!)
                if endTime > 3 && mBleMessage.otaUpate {
                    
                    firmwareAnalysis.upgradeState = .WRITE
                    startTime = Date().secondTime
                    endTime = 0
                    timeOut = 15000
                    
                }
                
                break
            case .WRITE:
                
                let programmeLength = firmwareAnalysis.programmeLength(data: firmwareAnalysis.firmwareData, offset: offset)
                
                if mBleMessage.otaUpate {
                    if offset <= firmwareAnalysis.firmwareData.count {
                        Logger.debug("STATE_WRITE \(offset) 总:\(firmwareAnalysis.firmwareData.count)")
                        let writeOTAData = firmwareAnalysis.programmeCommand(addr: offset+firmwareAnalysis.minAddr, data: firmwareAnalysis.firmwareData, offset: offset)
                        if offset == firmwareAnalysis.firmwareData.count {
                            offset += 100
                        }else{
                            offset += programmeLength
                            mBleMessage.Updatewrite(data: writeOTAData)
                            mBleMessage.otaUpate = false
                        }
                        
                    }else{
                        
                        firmwareAnalysis.upgradeState = .VERIFY
                        offset = 0
                        startTime = Date().secondTime
                        endTime = 0
                    }
                    
                }
                
                percentage = Float(offset) / Float(firmwareAnalysis.firmwareData.count)
                updateAlertView.percentageL.text = "\(Int(percentage*100))%"
                updateAlertView.updateCircleArcView.setProgress(Int(percentage*100))
                
                if !mBleMessage.isConnection {
                    firmwareAnalysis.upgradeState = .DISCONNECT
                }
                
            case .VERIFY:
                
                if !checksumBool && mBleMessage.bootInfoModel.support0x85Instruction == 1 {
                    checksumBool = true
                    let writeOTAData = firmwareAnalysis.checksumCommand()
                    mBleMessage.Updatewrite(data: writeOTAData)
                    mBleMessage.otaUpate = false
                    firmwareAnalysis.upgradeState = .END
                    firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                }else {
                    firmwareAnalysis.firmwareUpgradeErrorTimes += 0
                    let programmeLength = firmwareAnalysis.programmeLength(data: firmwareAnalysis.firmwareData, offset: offset)
                    
                    if mBleMessage.otaUpate {
                        if offset <= firmwareAnalysis.firmwareData.count {
                            Logger.debug("STATE_WRITE \(offset) 总:\(firmwareAnalysis.firmwareData.count)")
                            let writeOTAData = firmwareAnalysis.programmeCommand(addr: offset+firmwareAnalysis.minAddr, data: firmwareAnalysis.firmwareData, offset: offset)
                            
                            if offset == firmwareAnalysis.firmwareData.count {
                                offset += 100
                            }else{
                                offset += programmeLength
                                mBleMessage.Updatewrite(data: writeOTAData)
                                Thread.sleep(forTimeInterval: 3)
                                mBleMessage.otaUpate = false
                            }
                            
                        }else{
                            
                            firmwareAnalysis.upgradeState = .END
                            offset = 0
                            startTime = Date().secondTime
                            endTime = 0
                        }
                    }
                    
                    let percentage = Float(offset) / Float(firmwareAnalysis.firmwareData.count)
                    updateAlertView.percentageL.text = "\(Int(percentage*100))%"
                    updateAlertView.updateCircleArcView.setProgress(Int(percentage*100))
                    
                }
                
                if !mBleMessage.isConnection {
                    firmwareAnalysis.upgradeState = .DISCONNECT
                }
                
            case .END:
                Logger.debug("STATE_END")
                firmwareAnalysis.firmwareUpgradeErrorTimes = 0
                mBleMessage.currentDeviceScan!.peripheral!.readValue(for: (mBleMessage.currentDeviceScan?.characteristicFEE1)!)
                if !endBool && mBleMessage.otaUpate {
                    endBool = true
                    let writeOTAData = firmwareAnalysis.endCommand()
                    mBleMessage.Updatewrite(data: writeOTAData)
                    firmwareAnalysis.upgradeState = .SUCCESS
                }
                
            case .SUCCESS:
                break
            case .TIMEOUT:
                firmwareAnalysis.upgradeState = .TIMEOUT
                
            case .ERROR:
                firmwareAnalysis.upgradeState = .ERROR
                
            case .DISCONNECT:
                firmwareAnalysis.upgradeState = .DISCONNECT
                
            }
            endTime = (Date().secondTime - startTime)
            
            if .TIMEOUT != firmwareAnalysis.upgradeState && .ERROR != firmwareAnalysis.upgradeState &&
                .SUCCESS != firmwareAnalysis.upgradeState &&
                .DISCONNECT != firmwareAnalysis.upgradeState{
                DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + milliseconds, execute: dispatchWorkItem!)
            
            } else {
                
                content.title = name
                updateAlertView.removeFromSuperview()
                dispatchWorkItem?.cancel()
                dispatchWorkItem = nil
                mBleMessage.upgradeBool = false
                
                switch(firmwareAnalysis.upgradeState){

                case .TIMEOUT:
                    updateAlertView.removeFromSuperview()
                    
                    Alert.alert(title: NSLocalizedString("UpgradeTimeout", comment: "UpgradeTimeout"), controllerV: firmwareAnalysis.bleFirmwareAnalysisViewController!)
                    
                    
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " +  NSLocalizedString("UpgradeTimeout", comment: "UpgradeTimeout")
                    if internalBool {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bleOTA"), object: false)
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: false)
                    }
                case .ERROR:
                    
                    updateAlertView.removeFromSuperview()
                    
                    Alert.alert(title: NSLocalizedString("UpgradeFailed", comment: "UpgradeFailed"), controllerV: firmwareAnalysis.bleFirmwareAnalysisViewController!)
                    
                    
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " +  NSLocalizedString("UpgradeFailed", comment: "UpgradeFailed")
                    if internalBool {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bleOTA"), object: false)
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: false)
                    }
                case .SUCCESS:
                    mBleMessage.bootState = true
                    updateAlertView.removeFromSuperview()
                    Alert.alert(title: NSLocalizedString("UpgradeSuccessed", comment: "UpgradeSuccessed"), controllerV: firmwareAnalysis.bleFirmwareAnalysisViewController!)
                    
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " + NSLocalizedString("UpgradeSuccessed", comment: "UpgradeSuccessed")
                    
                    if internalBool {
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bleOTA"), object: true)
                        
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: false)
                    }
                case .DISCONNECT:
                    Alert.alert(title: NSLocalizedString("DeviceDisconnected", comment: "DeviceDisconnected"), controllerV: firmwareAnalysis.bleFirmwareAnalysisViewController!)
                    
                    content.body = NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware") + ": " + NSLocalizedString("DeviceDisconnected", comment: "DeviceDisconnected")
                    
                    if internalBool {
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bleOTA"), object: false)
                        
                    }else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: false)
                    }
                    
                default:
                    break
                }
                
                content.userInfo = ["userName": "isdt", "articleId": 12]
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
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                
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
                
            }
        }
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + milliseconds, execute: dispatchWorkItem!)
        
    }
    
}
