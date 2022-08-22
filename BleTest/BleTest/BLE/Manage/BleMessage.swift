//
//  BleMessage.swift
//  IOSApp
//
//  Created by gbt on 2022/5/9.
//

import Foundation
import CoreBluetooth

class BleMessage:  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    static let UUID_BLE_WRITE_FEE1 = "FEE1"  //FEE0特征
    static let UUID_BLE_WRITE_AF01 = "AF01"  //AF01特征
    static let UUID_BLE_WRITE_AF02 = "AF02"  //AF02特征
    
//    let heartRateServiceUUID = CBUUID(string: "0xAF00")
//    let heartRateServiceUUID1 = CBUUID(string: "0xFEE0")
    
    static let BLE_DO_OUTER_SCAN = 1
    static let BLE_DO_OUTER_COMM = 2
    static let BLE_DO_OUTER_IDLE = 3
    static let BLE_DO_OUTER_COMM_CONN = 4
    static let BLE_DO_OUTER_QUERY_VERSION = 5
    static let BLE_DO_OUTER_DISCONN = 6
    static let BLE_DO_OUTER_BIND = 7
    static let BLE_DO_SLEEP_TIME = 50
    

    let currentDeviceScanLock = NSRecursiveLock()
    var centralManager : CBCentralManager?
    static let sharedInstance = BleMessage()
    var currentDeviceScan: MyBluetoothDevice?
    var btAvailable:Bool = false
    var btState: CBManagerState = .unknown

    let bleConnecter = BleConnecter()
    let bleBinder = BleBinder()
    let bleVersionQuerier = BleVersionQuerier()
    var startTime = 0
    var bleDoOuter = 0
    
    let bleIdler = BleIdler()
    let bleScanner = BleScanner()
    let bleDisconnecter = BleDisconnecter()
    let bleCommunicater = BleCommunicater()
    var lastBleDoInterface: BleDoInterface? = nil
    var bootState = false
    var bleState:BleState = .IDLE

    
    var upgradeBool = false
    var isConnection = false
    
    var bootInfoModel = BootInfoModel()
    private let packCmdListLock = NSRecursiveLock()
    var packCmdUserList:[PackBase] = []
    var valNotifyTmp: [UInt8]? = nil
    var otaUpate = false
    var nameOk = false
    var named = false

    var findDeviceTest = false
    
    private var packCmdList:[PackBase] = []
    var packCmdOnceOnlyMap:[UInt16 : PackBase] = [:]
    var priorityCounter = 0
    var packCmdIndex = 0
    
    
    
    
    //重新定义闭包类型
    typealias ScanDeviceTypealias = (_ device: CBPeripheral, _ broadcastPacketAnalysis: BroadcastPacketAnalysis,
                                     _ scanPacketAnalysis: ScanPacketAnalysis)->()
    
    var scanDeviceTypealias: ScanDeviceTypealias?
        

    
    private override init() {
        super.init()
        
        initBluetooth()
//        packCmdList.removeAll()

    }
    
    func initBluetooth() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //BleMessage.swift(375)
    func setCurrentDevice(currentDeviceScan: MyBluetoothDevice?) {
        currentDeviceScanLock.lock()
        self.currentDeviceScan = currentDeviceScan
        currentDeviceScanLock.unlock()
    }
    
    func startCommConn() {
        startTime = Date().secondTime
        bleConnecter.connecting = false
        bleBinder.binding = false
        bleVersionQuerier.queried = true
        bleDoOuter = BleMessage.BLE_DO_OUTER_COMM_CONN
    }
    
    func startComm() {
        startTime = Date().secondTime
        bleDoOuter = BleMessage.BLE_DO_OUTER_COMM
    }
    
    // MARK: 停止扫描
    func stopScanDevice() {
        if !btAvailable {
            return
        }
        if centralManager!.isScanning {
            Logger.debug("Stop scan")
            centralManager!.stopScan()
        }
    }
    
    func connectDevice(device: CBPeripheral) {
        centralManager!.connect(device, options: nil)
        // setDeviceCurrent(peripheral: device)
    }
    
    func disconnectDevice(_ per: CBPeripheral?) {
        if nil != per {
            //bleDoOuter = BleMessage.BLE_DO_OUTER_IDLE
            centralManager!.cancelPeripheralConnection(per!)
            //currentDeviceScan!.peripheral = nil
            
            
            Logger.debug("断开连接")
        }
    }
    
    
    //DeviceView.swift(237)
    func disconnectDevice() {
        bleConnecter.clear()
        startTime = 0
        if nil != currentDeviceScan {
            disconnectDevice(currentDeviceScan!.peripheral)
        }
    }
    
    func reconnectDevice(_ per: CBPeripheral?) {
        
        if nil != currentDeviceScan {
            centralManager!.cancelPeripheralConnection(per!)
        }
        
    }
    
    func putPackBaseUserList(packBase: PackBase) {
        packCmdListLock.lock()
        packCmdUserList.append(packBase)
        packCmdListLock.unlock()
    }
    
    //DeviceView.swift(238)
    func clearPackCmdBaseUserList() {
        packCmdListLock.lock()
        packCmdUserList.removeAll()
        packCmdListLock.unlock()
    }
    
    //UpgradeHandle.swift(52)
    func clearPackCmdList() {
        packCmdListLock.lock()
        packCmdList.removeAll()
        packCmdListLock.unlock()
    }
    
    //BleUpgradeHandle.swift(88)
    func Updatewrite(data: [UInt8]) {
        let bleMessage = BleMessage.sharedInstance
        bleMessage.currentDeviceScan!.writeUpdateData(updateData: data)
        
    }
    
    func bleDo(packBaseWrite: PackBase?, packBaseReadList: inout [PackBase]) -> BleState {
        switch bleDoOuter {
        case BleMessage.BLE_DO_OUTER_IDLE:
            bleState = .DISCONN
            if nil != lastBleDoInterface {
                lastBleDoInterface?.clear()
            }
        case BleMessage.BLE_DO_OUTER_SCAN:
            bleState = BleState.SCAN
            bleDoOuter = 0
        case BleMessage.BLE_DO_OUTER_COMM:
            bleState = BleState.SCAN
            bleDoOuter = 0
        case BleMessage.BLE_DO_OUTER_COMM_CONN:
            bleState = BleState.CONNECT
            bleDoOuter = 0
        case BleMessage.BLE_DO_OUTER_BIND:
            bleBinder.clear()
            bleState = BleState.BIND
            bleDoOuter = 0
        case BleMessage.BLE_DO_OUTER_QUERY_VERSION:
            bleState = BleState.QUERY_VERSION
            bleDoOuter = 0
        case BleMessage.BLE_DO_OUTER_DISCONN:
            bleState = BleState.DISCONN
            bleDoOuter = 0
        default:
            //Logger.debug("bleDo: default")
            break
        }
        
        switch bleState {
        case .IDLE:
            lastBleDoInterface = bleIdler
            bleState = bleIdler.bleDo()
            if BleState.IDLE != bleState {
                bleIdler.clear()
                lastBleDoInterface = bleScanner
            }
        case .SCAN:
            lastBleDoInterface = bleScanner
            bleState = bleScanner.bleDo()
            if BleState.SCAN != bleState {
                bleScanner.clear()
                lastBleDoInterface = bleConnecter
            }
        case .CONNECT:
            lastBleDoInterface = bleConnecter
            bleState = bleConnecter.bleDo()
            if bleState != BleState.CONNECT {
                bleConnecter.clear()
                lastBleDoInterface = bleBinder
            }
        case .BIND:
            lastBleDoInterface = bleBinder
            bleState = bleBinder.bleDo()
            if bleState != BleState.BIND {
                if BleState.BIND_INFO_CHANGED == bleState {
                    bleBinder.clear()
                    bleDisconnecter.bleDo()
                    bleDisconnecter.clear()
                    lastBleDoInterface = bleIdler
                } else {
                    bleBinder.clear()
                    lastBleDoInterface = bleVersionQuerier
                }
            }
        case .QUERY_VERSION:
            lastBleDoInterface = bleVersionQuerier
            bleState = bleVersionQuerier.bleDo()
            if bleVersionQuerier.packBaseRead != nil {
                
                packBaseReadList.append(bleVersionQuerier.packBaseRead!)
            }
            if bleState != BleState.QUERY_VERSION {
                bleVersionQuerier.clear()
                lastBleDoInterface = bleCommunicater
            }
        case .COMMUNICATION:
            lastBleDoInterface = bleCommunicater
            if bleCommunicater.packBaseWrite == nil {
                bleCommunicater.packBaseWrite = packBaseWrite
            }
            bleState = bleCommunicater.bleDo()
            if bleCommunicater.packBaseRead != nil {
                packBaseReadList.removeAll()
                packBaseReadList.append(bleCommunicater.packBaseRead!)
                bleCommunicater.packBaseWrite = nil
            }
            if bleState != BleState.COMMUNICATION {
                bleCommunicater.clear()
                lastBleDoInterface = bleCommunicater
            }
        case .DISCONN:
            lastBleDoInterface = bleDisconnecter
            bleState = bleDisconnecter.bleDo()
            if bleState != BleState.DISCONN {
                bleDisconnecter.clear()
                lastBleDoInterface = bleScanner
            }
            // case .BIND_INFO_CHANGED:
        default:
            if lastBleDoInterface != nil {
                lastBleDoInterface?.clear()
            }
            bleState = bleDisconnecter.bleDo()
            if bleState != BleState.DISCONN {
                bleDisconnecter.clear()
                lastBleDoInterface = bleScanner
            }
            Logger.debug("isdtBleState: default")
        }
        
        return bleState
    }
    
    func getNextPack() -> PackBase? {
        
        var packBase: PackBase? = nil
        let packCmdOnceOnly = packCmdOnceOnlyMap.sorted(by: {$0.key < $1.key})
        packCmdListLock.lock()
        
        if !packCmdUserList.isEmpty {
            packBase = packCmdUserList[0]
        } else {
            priorityCounter += 1
            if packCmdOnceOnlyMap.isEmpty {
                if !packCmdList.isEmpty && packCmdList.count != 0  && packCmdIndex < packCmdList.count{
                    //Logger.debug("start packCmdIndex: \(packCmdIndex)")
                    packBase = packCmdList[packCmdIndex]
                    packCmdIndex += 1
                    if packCmdIndex >= packCmdList.count {
                        packCmdIndex = 0
                    }
                }else {
                    if packCmdList.count != 0 {
                        packBase = packCmdList[0]
                        packCmdIndex = 0
                    }
                }
                
            } else {
                packBase = packCmdOnceOnly.first?.value
            }
        }
        
        packCmdListLock.unlock()
        
        return packBase
    }
    
    
    // MARK: 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            btAvailable = false
            Logger.debug("unknown")
        case .resetting:
            btAvailable = false
            Logger.debug("resetting")
        case .unsupported:
            btAvailable = false
            Logger.debug("unsupported")
        case .unauthorized:
            btAvailable = false
            Logger.debug("unauthorized")
        case .poweredOff:
            btAvailable = false
            Logger.debug("poweredOff")
        case .poweredOn:
            btAvailable = true
            Logger.debug("poweredOn")
//            startScanDevice()
           
        @unknown default:
            Logger.debug("default")
        }
        btState = central.state
    }
    
    
    // MARK: 扫描设备
    func startScanDeviceData() {

        if !btAvailable {
            return
        }
        
        setCurrentDevice(currentDeviceScan: nil)
        
        if !centralManager!.isScanning {
            Logger.debug("开始扫描")
            let heartRateServiceCBUUID = CBUUID(string: "0xAF00")
            let heartRateServiceCBUUID1 = CBUUID(string: "0xFEE0")
            
            //扫描正在广播的外设
            centralManager!.scanForPeripherals(withServices: [heartRateServiceCBUUID, heartRateServiceCBUUID1], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
  
        }
    }
    
    
    //MARK: 设备回调, 中心设备扫描外设并连接
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        

        guard let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? NSData else {
            return
        }
        guard let scanData = advertisementData["kCBAdvDataLocalName"] as? String else {
            return
        }

//        print("\(manufacturerData)")
        if manufacturerData.count == 22 {
            //创建广播数据数组，存放外设厂商提供的自定义数据CBAdvertisementDataManufacturerDataKey
            var manufacturerDatabyte:[UInt8] = []
            
            for value in manufacturerData {
                manufacturerDatabyte.append(value)
            }
            //外设的当前接收信号强度指示 (RSSI)，以分贝为单位，一般在-30到-99之间，-30最强
            //将广播数据数组存放到class BroadcastPacketAnalysis
            let broadcastPacketAnalysis = BroadcastPacketAnalysis.init(bytes: manufacturerDatabyte)
            broadcastPacketAnalysis.rssi = RSSI
            let scanPacketAnalysis = ScanPacketAnalysis.init(dataString: scanData)

//            print("\(broadcastPacketAnalysis)")
            if broadcastPacketAnalysis.manufacturerID == 4205816762 {
                if scanDeviceTypealias != nil {
                    scanDeviceTypealias!(peripheral, broadcastPacketAnalysis, scanPacketAnalysis)
                }
            }
        }

        if currentDeviceScan != nil {
            //比较currentDeviceScan!.identifier 与 peripheral.identifier.uuidString 是否相等
            if .orderedSame == currentDeviceScan!.identifier.caseInsensitiveCompare(peripheral.identifier.uuidString) {
                bleScanner.found = true
                bleConnecter.connected = false
                currentDeviceScan?.peripheral = peripheral
                stopScanDevice()

            }
        }

    }
    
    //MARK: 设备接成功,外设自行寻找Service
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        Logger.debug("设备连接成功")
        stopScanDevice()
        peripheral.delegate = self
        //discoverServices(_ serviceUUIDs: [CBUUID]?) 找到外设服务，nil代表接受所有uuid的服务
        peripheral.discoverServices(nil)
        isConnection = true
    }

    // MARK: 设备连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Logger.debug("设备连接失败, device\(peripheral.name!),reason\(String(describing: error))")
        isConnection = false
    }

    // MARK: 设备连接断开
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Logger.debug("设备连接断开, device\(peripheral.name!),reason\(String(describing: error))")
//        central.connect(peripheral)         //重新连接外设
        isConnection = false
    }
    


    // MARK: 发现服务调用,已发现服务（或发现失败）
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Logger.debug("已发现服务")
        if let error = error {
            print("没找到服务，原因是\(error.localizedDescription)")
        }

        if peripheral.services?.count == 0 {
            Logger.debug("No services")
        }
        currentDeviceScan?.characteristicFEE1 = nil
        currentDeviceScan?.characteristicAF01 = nil
        currentDeviceScan?.characteristicAF02 = nil
        
        for service: CBService in peripheral.services! {
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    
    // MARK: 根据服务找特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("没找到特征，原因是\(error.localizedDescription)")
        }
        
        guard let characteristics = service.characteristics else{return}
            for characteristic in characteristics{
                if characteristic.uuid.uuidString.caseInsensitiveCompare(BleMessage.UUID_BLE_WRITE_AF01) == .orderedSame {
                    Logger.debug("characteristicAF01: \(characteristic.uuid)")
                    let uuid = peripheral.identifier.uuidString
                    currentDeviceScan?.identifier = uuid
                    currentDeviceScan?.characteristicAF01 = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid.uuidString.caseInsensitiveCompare(BleMessage.UUID_BLE_WRITE_AF02) == .orderedSame {
                    Logger.debug("characteristicAF02: \(characteristic.uuid)")
                    let uuid = peripheral.identifier.uuidString
                    currentDeviceScan?.identifier = uuid
                    currentDeviceScan?.characteristicAF02 = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid.uuidString.caseInsensitiveCompare(BleMessage.UUID_BLE_WRITE_FEE1) == .orderedSame {
                    Logger.debug("FEE0didFindfind: \(characteristic.uuid)")
                    let uuid = peripheral.identifier.uuidString
                    currentDeviceScan?.identifier = uuid
                    currentDeviceScan?.characteristicFEE1 = characteristic
                    currentDeviceScan?.peripheralFEE1 = peripheral
                }

            }
        findDeviceTest = true
        
    }
    
    // MARK: 发送数据回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if nil != error {
            Logger.debug("写入数据失败: \(String(describing: error))")
            return
        }
        if characteristic == currentDeviceScan?.characteristicFEE1 {
            peripheral.readValue(for: characteristic)
        }
        
        if currentDeviceScan?.packSend != nil {
            currentDeviceScan!.packSend!.sent = true
//            let packSendTmp = PackBase.assemblePackSend(packBase: nil)
//            if nil != packSendTmp {
                //currentDeviceScan!.packSend = packSendTmp
                //currentDeviceScan!.doPackSend(packSend: currentDeviceScan!.packSend)
//            }
        }
    }
    
    // MARK: 订阅特征成功
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("订阅失败，原因是\(error.localizedDescription)")
            return
        }else {
            Logger.debug("characteristic \(characteristic)")
            //特征的uuid 与 BleMessage.UUID_BLE_WRITE_AF02 相等，使connected（bool）为true
            if characteristic.uuid.uuidString.caseInsensitiveCompare(BleMessage.UUID_BLE_WRITE_AF02) == .orderedSame {
                bleConnecter.connected = true
            }
        }
    }
    
    // MARK: 接收数据
    //特征值已更新—— 1.读取特征值时调用 2.订阅特征值成功后，每当这个值变化时都会调用
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("读取失败，原因是\(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            return
        }
        valNotifyTmp = [UInt8](data)
        Logger.debug("data\(String(describing: valNotifyTmp))")
        
        //1.读取成功 2.订阅成功后值发生变化时，执行以下代码
        switch characteristic{
        case currentDeviceScan!.characteristicFEE1:
           
//            print("执行currentDeviceScan!.characteristicFEE1")
            if !valNotifyTmp!.isEmpty {
                
                if bootInfoModel.blockSize == 0 && valNotifyTmp![0] != 0 {
                    if data[0] == 1{
                        bootInfoModel.type = "B"
                    }else {
                        bootInfoModel.type = "A"
                    }
                    bootInfoModel.offset = Int(data[1])
                    bootInfoModel.offset |= (Int(data[2]) << 8)
                    bootInfoModel.offset |= (Int(data[3]) << 16)
                    bootInfoModel.offset |= (Int(data[4]) << 24)
                    bootInfoModel.blockSize = Int((data[6] & 0xFF))*256+(Int(data[5]) & 0xFF)
                    bootInfoModel.support0x85Instruction = Int(data[7])
                    bootInfoModel.appID = Int(data[8])
                }else {
                    //if valNotifyTmp![0] == 0 {
                    otaUpate = valNotifyTmp![0] == 0
                    //}
                }
            }
            
        case currentDeviceScan!.characteristicAF01:

//            print("执行currentDeviceScan!.characteristicAF01")
            if valNotifyTmp!.count < 2 {
                return
            }
            
            switch valNotifyTmp![1] {
                
            case RenameResp.CMD_WORD:
                let renameResp = RenameResp()
                renameResp.parse(cmd: valNotifyTmp)
                if renameResp.state {
                    nameOk = true
                    for i in 0..<packCmdUserList.count {
                        if i<packCmdUserList.count{
                            if ((packCmdUserList[i] as? RenameResp) != nil) {
                                packCmdListLock.lock()
                                packCmdUserList.remove(at: i)
                                packCmdListLock.unlock()
                            }
                        }
                    }
                } else {
                    nameOk = false
                }
                named = true
                
            case HardwareInformationResp.CMD_WORD:
                let hardwareInformationResp = HardwareInformationResp()
                hardwareInformationResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = hardwareInformationResp
                bleVersionQuerier.queried = true
                
            case ElectricResp.CMD_WORD:
                let electricResp = ElectricResp()
                electricResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = electricResp
                
            case PS200WorkingStatusResp.CMD_WORD:
                let pS200WorkingStatusResp = PS200WorkingStatusResp()
                pS200WorkingStatusResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = pS200WorkingStatusResp
                
            case PS200DCStatusResp.CMD_WORD:
                let pS200DCStatusResp = PS200DCStatusResp()
                pS200DCStatusResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = pS200DCStatusResp
                
            case WorkTasksResp.CMD_WORD:
                let packBaseRet = WorkTasksResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
                
            case ChargerWorkStateResp.CMD_WORD:
                let chargerWorkStateResp = ChargerWorkStateResp()
                chargerWorkStateResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = chargerWorkStateResp
                
            case IRResp.CMD_WORD:
                let packBaseRet = IRResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = packBaseRet
                
            case AlarmToneResp.CMD_WORD:
                let packBaseRet = AlarmToneResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = packBaseRet
                
            case AlarmToneTaskResp.CMD_WORD:
                let packBaseRet = AlarmToneTaskResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
                
            case OTAUpgradeCmdResp.CMD_WORD:
                let packBaseRet = OTAUpgradeCmdResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bootState = packBaseRet.state
                bleCommunicater.packBaseRead = packBaseRet
                
            case OTAEraseResp.CMD_WORD:
                let packBaseRet = OTAEraseResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
                
            case OTAWriteResp.CMD_WORD:
                let packBaseRet = OTAWriteResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
                
            case OTAChecksumResp.CMD_WORD:
                let packBaseRet = OTAChecksumResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
                
            case OTARebootResp.CMD_WORD:
                let packBaseRet = OTARebootResp()
                packBaseRet.parse(cmd: valNotifyTmp)
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseRet
            default:
                break
            }
            bleCommunicater.communicated = true
            
        case currentDeviceScan!.characteristicAF02:
            
//            print("执行currentDeviceScan!.characteristicAF02")
            switch valNotifyTmp![0] {
            case BindingResponse.CMD_WORD:
                let packBaseRet = BindingResponse()
                packBaseRet.parse(cmd: valNotifyTmp)
                switch packBaseRet.bound {
                case 0:
                    Logger.debug("开始写入，Bind 成功")
                    bleBinder.bound = true
                    bleCommunicater.communicated = true
                    break
                case 1:
                    Logger.debug("Bind等待确认绑定")
                    bleBinder.binding = false
                    break
                default:
                    bleBinder.boundInfoChanged = true
                    Logger.debug("Bind error:\(packBaseRet.bound)")
                }
                bleCommunicater.packBaseRead = packBaseRet
                
            case HardwareInformationResp.CMD_WORD:
                let hardwareInformationResp = HardwareInformationResp()
                hardwareInformationResp.parse(cmd: valNotifyTmp)
                bleCommunicater.packBaseRead = hardwareInformationResp
                bleCommunicater.communicated = true
                bleVersionQuerier.queried = true
            default:
                break
            }
            
            guard let packBaseTmp = PackBase.parsePack(valNotifyTmp!) else {
                return
            }
            packBaseTmp.readFlag = true
            if let bindingResponse = packBaseTmp as? BindingResponse {
                switch bindingResponse.bound {
                case 0:
                    Logger.debug("start write Bind ok")
                    bleBinder.bound = true
                    bleCommunicater.communicated = true
                    break
                case 1:
                    Logger.debug("Bind等待确认绑定")
                    bleBinder.binding = false
                    break
                default:
                    bleBinder.boundInfoChanged = true
                    Logger.debug("Bind error:\(bindingResponse.bound)")
                }
                bleCommunicater.packBaseRead = packBaseTmp
            }else if (packBaseTmp as? HardwareInformationResp) != nil {
                bleCommunicater.packBaseRead = packBaseTmp
                bleCommunicater.communicated = true
                bleVersionQuerier.queried = true
            } else if (packBaseTmp as? OTAWriteResp) != nil {
                clearPackCmdBaseUserList()
                bleCommunicater.packBaseRead = packBaseTmp
                bleCommunicater.communicated = true
            }
            
        default:
            break
        }

    }
    
    
}
