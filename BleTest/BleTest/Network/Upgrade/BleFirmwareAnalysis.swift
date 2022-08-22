//
//  BleFirmwareAnalysis.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation
import UIKit

enum BleUpgradeState {
    
    case CONNECT
    case UPGRADE
    case RECONNECT
    case ERASE
    case WRITE
    case VERIFY
    case END
    case SUCCESS
    case ERROR
    case TIMEOUT
    case DISCONNECT
    
}


class BleFirmwareAnalysis {
    
    let FIRMWARE_UPGRADE_MAX_ERROR_TIMES = 16500
    static let FIRMWARE_UPGRADE_INTERVAL: DispatchTimeInterval = DispatchTimeInterval.seconds(1)
    
    var bleUpgradeMode: UpgradeMode?
    var myDevice:MyBluetoothDevice?
    var upgradeClbk: ((_ path: URL?)->())?
    var firmwareUpgradeErrorTimes = 0
    var upgradeState: BleUpgradeState = .ERASE
    var handlerPeriod = FIRMWARE_UPGRADE_INTERVAL
    
    var firmwareData:[UInt8] = []   //固件数据
    var totalLen = 0                //固件总长度
    var minAddr = -1                 //起始地址
    var maxAddr = -1                //终止地址
    var maxAddrDataLen = 0          //用来记录最大地址所在包的数据长度，用来确定分配数组的大小
    var lAddr = 0
    var list: [FileElement] = []
    var checksum: UInt64 = 0
    let mBleMessage = BleMessage.sharedInstance
    var firmwareFile: URL? = nil
    var downloaderFile: URL? = nil
    lazy var bleFirmwareAnalysisViewController: UIViewController? = nil
    var sendSize = 132
    var command = 0x80
    var addMultiple = 4
    var type = ""
    
    init(bleUpgradeMode: UpgradeMode?, myDevice: MyBluetoothDevice?) {
        self.bleUpgradeMode = bleUpgradeMode
        self.myDevice = myDevice
        self.upgradeClbk = nil
        
    }
    
    class FileElement {
        
        var addr:Int = 0
        var len:Int = 0
        var data:[UInt8] = []
    }
    
    class FileStruc {
        let start = ":"           //每一条Hex记录的起始字符“:”
        var length = 0x00         //数据的字节数量
        var address = 0x0000      //数据存放的地址
        var type = 0xFF           //HEX记录的类型
        var data:[UInt8] = []     //一行最多有16个字节的数据
        var check = 0xAA          //校验和
        var offset = 0x0000       //偏移量
        var format = 0x00         //数据行所从属的记录类型
    }
    
    func loadFirmware(fileUrl: URL?) -> Bool {
        list = []
        if nil == fileUrl {
            Logger.debug("文件不存在")
            return false
        }
        firmwareFile = fileUrl
        var readHandler:FileHandle? = nil
        do {
            readHandler = try! FileHandle(forReadingFrom: fileUrl!)
            let data = readHandler!.readDataToEndOfFile()
            let readString = String(data: data, encoding: String.Encoding.utf8)
            
            let fileStruct = FileStruc()
            
            let readArray = readString?.components(separatedBy: "\r\n")
            
            for i in 0..<readArray!.count {
                
                let read = readArray![i]
                
                if read[0] != ":" {
                    Logger.debug("数据不符合")
                    return false
                }
                let index = read.index(read.startIndex, offsetBy: 1)
                if !hexStringValid(string: String(read[index...])){
                    Logger.debug("数据不符合十六进制")
                    return false
                }
                if read.count < 11 {
                    Logger.debug("数据不符合,数据不超过11个字节")
                    return false
                }
                
                fileStruct.length = Int(read[1..<3], radix: 16)!
                fileStruct.offset = Int(read[3..<7], radix: 16)!
                fileStruct.type = Int(read[7..<9], radix: 16)!
                fileStruct.data = hexStringByteArray(hexString: (read[9..<9+fileStruct.length*2]))
                fileStruct.check = Int(read[9+fileStruct.length*2..<9+fileStruct.length*2+2], radix: 16)!
                if fileStruct.type == 0x00 {
                    
                    switch fileStruct.format {
                    case 0x00:
                        lAddr = fileStruct.offset
                    case 0x02:
                        lAddr = (fileStruct.address << 4) + fileStruct.offset
                    case 0x04:
                        lAddr = (fileStruct.address << 16) + fileStruct.offset
                    default:
                        Logger.debug("无效的类型!")
                        return false
                    }
                    
                    if minAddr < 0 {
                        //第一次
                        minAddr = lAddr
                    }else {
                        if lAddr < minAddr {
                            minAddr = min(lAddr, minAddr)
                        }
                    }
                    if maxAddr < 0 {
                        //第一次
                        maxAddr = lAddr
                        maxAddrDataLen = fileStruct.data.count
                    }else{
                        //引入maxAddr_Data_Len
                        maxAddr = max(lAddr, maxAddr)
                        if lAddr == maxAddr {
                            //更新了最大地址
                            maxAddrDataLen = fileStruct.data.count
                        }
                    }
                    
                    let hexRec = FileElement()
                    hexRec.addr = lAddr
                    hexRec.len = fileStruct.length
                    hexRec.data = fileStruct.data
                    var s = ""
                    for i in 0..<fileStruct.data.count {
                        s += String(format: "%02x", fileStruct.data[i])
                    }
                    //Logger.debug("readData: " + s)
                    
                    list.append(hexRec)
                    totalLen += hexRec.data.count
                    //Logger.debug("total size: \(totalLen)")
                    
                }else if fileStruct.type == 0x01 { //本行的数据类型为“文件结束记录”
                    //跳出循环
                    fileStruct.format = 0x01
                    break
                }else if fileStruct.type == 0x02 {//本行的数据类型为“扩展段地址记录”
                    //扩展段地址记录的数据个数一定是0x02
                    if fileStruct.length != 0x02 {
                        Logger.debug("不正确的长度")
                        return false
                    }
                    if fileStruct.offset != 0x0000 {
                        Logger.debug("不正确的地址")
                        return false
                    }
                    //更改从属的数据类型
                    fileStruct.format = 0x02
                    //获取段地址
                    let data = fileStruct.data
                    fileStruct.address = Int(data[0])
                    fileStruct.address <<= 8
                    fileStruct.address |= Int(data[1])
                    Logger.debug("0x02起始段地址记录: \(fileStruct.address) + \(read)")
                }else if fileStruct.type == 0x03 {
                    Logger.debug("起始段地址记录:忽略")
                }else if fileStruct.type == 0x04 {
                    //扩展线性地址记录中的数据个数一定是0x02
                    if fileStruct.length != 0x02 {
                        Logger.debug("不正确的长度")
                        return false
                    }
                    if fileStruct.offset != 0x0000 {
                        Logger.debug("不正确的地址")
                        return false
                    }
                    //更改从属的数据类型
                    fileStruct.format = 0x04
                    //获取段地址
                    let data = fileStruct.data
                    fileStruct.address = Int(data[0])
                    fileStruct.address <<= 8
                    fileStruct.address |= Int(data[1])
                    Logger.debug("0x04起始段地址记录: \(fileStruct.address) + \(read)")

                }else if fileStruct.type == 0x05 {
                    Logger.debug("开始线性地址记录:忽略")
                }else{
                    Logger.debug("此类型未定义")
                }
            }
            
            Logger.debug("最后的总大小:\(totalLen)")
            Logger.debug("起始地址: \(minAddr)")
            Logger.debug("终止地址: \(maxAddr)")
            Logger.debug("最大地址: \(maxAddrDataLen)")
            
            //由于地址不连续，totalLen 可能缺少
            //数组可能由maxAddr-minAddr+maxAddr_Data_Len分配
            let realSize = maxAddr-minAddr+maxAddrDataLen
            if realSize != totalLen {
                Logger.debug("hex文件地址不连续：realSize->\(+realSize) totalLen\(totalLen) + \(String(describing: read))")
            }
            totalLen = max(realSize, totalLen)
            
            var firmwareDatas = [UInt8](repeating: 0, count: totalLen)
            for i in 0..<list.count {
                let offset = list[i].addr - minAddr
                for b in 0..<list[i].data.count {
                    firmwareDatas[offset+b] = list[i].data[b]
                }
                
            }
            checksum = 0
            firmwareData = firmwareDatas
            for i in stride(from: 0, to: firmwareData.count, by: 4){
                var value = UInt32(firmwareData[i])
                value |= (UInt32(firmwareData[i+1]) << 8)
                value |= (UInt32(firmwareData[i+2]) << 16)
                value |= (UInt32(firmwareData[i+3]) << 24)
                checksum += UInt64(value)
                checksum &= 0xFFFFFFFF
//                Logger.debug("当前长度：\(checksum)" + "总长度：\(i)")
            }
            return true
        }
        
    }
    
    //判断数据是否属于十六进制
    func hexStringValid(string: String) -> Bool {
        let hexArray =  string.map { String($0) }
        
        for i in 0..<hexArray.count{
            if (0 <= hexadecimalToDecimal(str: hexArray[i]) && hexadecimalToDecimal(str: hexArray[i]) <= 9) ||
                (10 <= hexadecimalToDecimal(str: hexArray[i]) && hexadecimalToDecimal(str: hexArray[i]) <= 16){
                
            }else{
                return false
            }
            
        }
        return true
    }
    
    //十六进制换算
    func hexadecimalToDecimal(str: String) -> Int {
        
        var sum = 0
        for i in str.utf8 {
            // 0-9 从48开始
            sum = sum * 16 + Int(i) - 48
            // A-Z 从65开始，但有初始值10，所以应该是减去55
            if i >= 65 {
                sum -= 7
            }
        }
        return sum
    }
    
    //字符串转换为字节数组
    func hexStringByteArray(hexString: String) -> [UInt8] {
        
        if hexString == "" {
            return []
        }
        
        let hexStrings = hexString.uppercased()
        let length = hexStrings.count/2
        let hexChars =  hexStrings.map { String($0) }
        var data:[UInt8] = []
        for i in 0..<length {
            data.append(UInt8(hexadecimalToDecimal(str:"\(hexChars[i*2])"+"\(hexChars[i*2+1])")))
        }
        
        return data
    }
    
    //BleUpgradeHandle.swift(108)
    func eraseCommand() -> [UInt8]{
        //v1.2--修改擦除块的计算方式
        let nBlocks = ((totalLen+(mBleMessage.bootInfoModel.blockSize-1))/mBleMessage.bootInfoModel.blockSize)
        var otaData:[UInt8] = []
        otaData.append(0x81)
        otaData.append(0x00)
        otaData.append(UInt8((minAddr/addMultiple) & 0xFF))
        otaData.append(UInt8(((minAddr/addMultiple) >> 8) & 0xFF))
        otaData.append(UInt8(nBlocks))
        otaData.append(UInt8(nBlocks >> 8))
//        for _ in 0..<14 {
//            otaData.append(0)
//        }
        return otaData
    }
    
    
    //BleUpgradeHandle.swift(125)
    func programmeLength(data: [UInt8], offset: Int) -> Int{
        return min(sendSize - 4, data.count - offset)
    }
    
    //BleUpgradeHandle.swift(130)
    func programmeCommand(addr: Int, data: [UInt8], offset: Int) -> [UInt8]{
        var otaData:[UInt8] = []
        otaData.append(UInt8(command))
        otaData.append(UInt8(sendSize - 4))
        otaData.append(UInt8((addr/addMultiple) & 0xFF))
        otaData.append(UInt8((addr/addMultiple) >> 8) & 0xFF)
        let len = min(sendSize - 4, data.count - offset)
        for i in 0..<len{
            otaData.append(data[offset+i])
        }
        if otaData.count < sendSize+1 {
            for _ in 0..<sendSize-otaData.count {
                otaData.append(0)
            }
        }
        return otaData
    }
    
    //BleUpgradeHandle.swift(161)
    func checksumCommand() -> [UInt8]{
        let addr = minAddr/addMultiple
        var otaData:[UInt8] = []
        otaData.append(0x85)
        otaData.append(0)
        otaData.append(UInt8(addr & 0xFF))
        otaData.append(UInt8((addr >> 8) & 0xFF))
        otaData.append(UInt8(firmwareData.count  & 0xFF))
        otaData.append(UInt8((firmwareData.count >> 8) & 0xFF))
        otaData.append(UInt8((firmwareData.count >> 16) & 0xFF))
        otaData.append(UInt8((firmwareData.count >> 24) & 0xFF))
        otaData.append(UInt8(checksum & 0xFF))
        otaData.append(UInt8((checksum >> 8) & 0xFF))
        otaData.append(UInt8((checksum >> 16) & 0xFF))
        otaData.append(UInt8((checksum >> 24) & 0xFF))
        return otaData
    }
    
    //BleUpgradeHandle.swift(209)
    func endCommand() -> [UInt8] {
        var otaData:[UInt8] = []
        otaData.append(0x83)
        otaData.append(18)
        for _ in 0..<18 {
            otaData.append(0)
        }
        return otaData
    }
    
    //BleUpgradeHandle.swift(393)
    func show() {
        let downloader = Downloader.sharedInstance
        if nil == bleUpgradeMode {
            //hud?.hide(animated: true)
            return
        }
        //        BleMng.sharedInstance.upgradeClear()
        downloader.downloadBle(fwdUrl: bleUpgradeMode!.url, upgradeClbk: upgradeClbk, type: type)
    }
    
    
}
