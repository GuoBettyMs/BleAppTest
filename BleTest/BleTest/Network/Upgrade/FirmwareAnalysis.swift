//
//  FirmwareAnalysis.swift
//  IOSApp
//
//  Created by gbt on 2022/5/12.
//

import Foundation
import UIKit

enum FirmwareUpgradeState {
    
    case CONNECT
    case UPGRADE
    case ERASE
    case RECONNECT
    case WRITE
    case VERIFY
    case REBOOT
    case SUCCESS
    case ERROR
    case TIMEOUT
    
}

class FirmwareAnalysis {
    
    var firmwareUpgradeErrorTimes = 0
    var FIRMWARE_UPGRADE_MAX_ERROR_TIMES = 200
    var upgradeState: FirmwareUpgradeState = FirmwareUpgradeState.CONNECT
    let FIRMWARE_HEADER_SIZE:UInt32 = 32
    let FIRMWARE_SIZE_LIMIT = 5000000
    var encryptionKey:UInt32 = 0
    var fileChecksum:UInt64 = 0
    var appStorageOffset:UInt32 = 0
    var dataStorageOffset:UInt32 = 0
    var appSize:UInt32 = 0
    var dataSize:UInt32 = 0
    var originalBaudRate:UInt32 = 0
    var rapidBaudRate:UInt32 = 0
    var firmwareData:[UInt8] = []
    var writeBuf:[UInt8] = []
    var sizeWritten:UInt32 = 0
    var sizeWrittens:UInt32 = 0
    var appStartAddress:UInt32 = 0
    var upgradeMode: UpgradeMode?
    var myDevice:MyBluetoothDevice?
    var upgradeClbk: ((_ path: URL?)->())?
    lazy var firmwareAnalysisViewController: UIViewController? = nil
    
    init(upgradeMode: UpgradeMode?, myDevice: MyBluetoothDevice?) {
        self.upgradeMode = upgradeMode
        self.myDevice = myDevice
        self.upgradeClbk = nil
        
    }
    
    func loadFirmware(fileUrl: URL?) -> Bool {
        var ret = false
        if nil == fileUrl {
            return ret
        }
        var readHandler:FileHandle? = nil
        
        readHandler = try! FileHandle(forReadingFrom: fileUrl!)
        var data = readHandler!.readData(ofLength: 4)
        
//        let datas = readHandler!.availableData
//        let readString = String(data: datas, encoding: String.Encoding.utf8)
        
        encryptionKey = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        fileChecksum = UInt64(MathUtil.getBigEndianU32s(data: data))
        data = readHandler!.readData(ofLength: 4)
        appStorageOffset = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        dataStorageOffset = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        appSize = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        dataSize = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        originalBaudRate = MathUtil.getBigEndianU32s(data: data)
        data = readHandler!.readData(ofLength: 4)
        rapidBaudRate = MathUtil.getBigEndianU32s(data: data)
        
        let sizeAll = FIRMWARE_HEADER_SIZE + appSize + dataSize
        if sizeAll > FIRMWARE_SIZE_LIMIT {
            readHandler?.closeFile()
            return ret
        }
        
        let blockNum = (sizeAll - FIRMWARE_HEADER_SIZE) / 4
        var fileChecksumTmp = fileChecksum
        var longTmp:UInt64 = 0
        firmwareData.removeAll()
        
        for _ in 0..<blockNum {
            data = readHandler!.readData(ofLength: 4)
            longTmp = UInt64(MathUtil.getBigEndianU32s(data: data))
            longTmp &= 0xFFFFFFFF
            longTmp ^= fileChecksumTmp
            fileChecksumTmp += UInt64(encryptionKey)
            fileChecksumTmp ^= UInt64(encryptionKey)
            
            firmwareData.append(UInt8((longTmp >> 0) & 0xFF))
            firmwareData.append(UInt8((longTmp >> 8) & 0xFF))
            firmwareData.append(UInt8((longTmp >> 16) & 0xFF))
            firmwareData.append(UInt8((longTmp >> 24) & 0xFF))
        }
        
        var checksum:UInt64 = 0
        let blockNum2 = firmwareData.count / 4
        var tmp:UInt64 = 0
        for i in 0..<blockNum2 {
            longTmp = 0
            tmp = UInt64(firmwareData[i * 4 + 3] & 0xFF)
            longTmp += tmp
            longTmp <<= 8
            
            tmp = UInt64(firmwareData[i * 4 + 2] & 0xFF)
            longTmp += tmp
            longTmp <<= 8
            
            tmp = UInt64(firmwareData[i * 4 + 1] & 0xFF)
            longTmp += tmp
            longTmp <<= 8
            
            tmp = UInt64(firmwareData[i * 4 + 0] & 0xFF)
            longTmp += tmp
            
            checksum += longTmp
        }
        
        if (checksum & 0xFFFFFFFF) != (fileChecksum & 0xFFFFFFFF) {
            Logger.debug("upchecksum error: \(checksum)!=\(fileChecksum)")
        } else {
            Logger.debug("upchecksum ok: \(checksum)!=\(fileChecksum)  长度： \(firmwareData.count)")
            ret = clearAppFlag()
        }
        
        readHandler?.closeFile()
        
        //Logger.debug("analysisBool\(ret)")
        return ret
    }
    
    func clearAppFlag() -> Bool {
        if firmwareData.count < FIRMWARE_HEADER_SIZE {
            return false
        }

        var flagAddress:UInt64 = 0
        var tmp:UInt64 = 0
        
        tmp = UInt64(firmwareData[0x1C] & 0xFF)
        flagAddress |= (tmp << 0)
        
        tmp = UInt64(firmwareData[0x1D] & 0xFF)
        flagAddress |= (tmp << 8)
        
        tmp = UInt64(firmwareData[0x1E] & 0xFF)
        flagAddress |= (tmp << 16)
        
        tmp = UInt64(firmwareData[0x1F] & 0xFF)
        flagAddress |= (tmp << 24)
        
        flagAddress &= 0xFFFFFFFF
        
        let offset = Int(flagAddress - UInt64(appStorageOffset))
        
        firmwareData[offset] = 0xFF
        firmwareData[offset+1] = 0xFF
        firmwareData[offset+2] = 0xFF
        firmwareData[offset+3] = 0xFF

        return true
    }
    
    func show() {
        let downloader = Downloader.sharedInstance
        if nil == upgradeMode {
            //hud?.hide(animated: true)
            return
        }
        //        BleMng.sharedInstance.upgradeClear()
        downloader.download(fwdUrl: upgradeMode!.url, upgradeClbk: upgradeClbk)
    }
    
}
