//
//  TestBluetoothViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/4/28.
//
//IOS 蓝牙中心设备
//CoreBluetooth框架：1.创建全局变量centralManager，使用协议CBCentralManagerDelegate，调用centralManagerDidUpdateState进行中心设备蓝牙状态判定
//2.中心设备蓝牙开启后，对外设进行扫描，调用centralManager（didDiscover peripheral: CBPeripheral）寻找外设并connect(peripheral)
//3.立即调用centralManager（didConnect peripheral: CBPeripheral），外设Peripheral使用协议CBPeripheralDelegate，自行寻找设备didDiscoverServices
//4.立即调用peripheral(didDiscoverServices)，外设寻找特征discoverCharacteristics
//5.调用peripheral(didDiscoverCharacteristicsFor），外设对特征（write、read、notify）分别处理
//PS：执行read后会调用peripheral(didUpdateValueFor），执行notify后会先调用peripheral(didUpdateNotificationStateFor characteristic），等到notify值发生改变后，才会调用peripheral(didUpdateValueFor）


import UIKit
import CoreBluetooth

let heartRateServiceUUID = CBUUID(string: "180D")
let controlPointCharacteristicUUID =  CBUUID(string: "2A39")
let sensorLocationCharacteristicUUID =  CBUUID(string: "2A38")
let measurementCharacteristicUUID =  CBUUID(string: "2A37")

//自定义uuid
//let heartRateServiceUUID = CBUUID(string: "D5BE176D-046C-41D8-805E-FE18ED810E43")
//let controlPointCharacteristicUUID =  CBUUID(string: "983FDBCF-1A91-4EEA-B9BD-A286C0E57005")
//let sensorLocationCharacteristicUUID =  CBUUID(string: "1CB71F67-8556-4D12-930B-277C7C4CA232")
//let measurementCharacteristicUUID =  CBUUID(string: "D4D31C5B-2B88-4B5F-9AD7-8DBC2450A1B6")

class TestBluetoothViewController: UIViewController {

    @IBOutlet weak var controlPointTextFleld: UITextField!      //可写特征controlPointCharacteristic
    @IBOutlet weak var sensorLocationL: UILabel!                //可读特征sensorLocationCharacteristic
    @IBOutlet weak var heartRateL: UILabel!                     //可订阅特征measurementCharacteristic
    
    var centralManager: CBCentralManager? = nil
    var heartRateperipheral: CBPeripheral? = nil
    var controlPointCharacteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //创建全局的中心设备管理器——立即调用centralManagerDidUpdateState
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    //MARK: 手动给外设发射数据
    @IBAction func write(_ sender: Any) {
        guard let controlPointCharacteristic = controlPointCharacteristic else {
            return
        }

        heartRateperipheral!.writeValue(controlPointTextFleld.text!.data(using: .utf8)!, for: controlPointCharacteristic, type: .withResponse)
    }
    
    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }

}

//MARK: 中心设备协议
extension TestBluetoothViewController: CBCentralManagerDelegate{
    
    //MARK: 中心设备蓝牙状态判定
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        //确保中心设备支持蓝牙低能耗（BLE）并开启时才能继续操作
        switch central.state{
        case .unknown:
            print("未知")
        case .resetting:
            print("重置中")
        case .unsupported:
            print("本机不支持BLE蓝牙低能耗")
        case .unauthorized:
            print("未授权")
        case .poweredOff:
            print("蓝牙未开启")
        case .poweredOn:
            print("蓝牙开启")
            //扫描正在广播的外设—— 每当发现外设时都会调用didDiscover peripheral方法
            //withServices:[xx] —— 只扫描正在广播xx服务的外设，若nil则扫描所有外设（费电不推荐）
            //中心设备扫描正在广播的外设如heartRate,心率监测仪固定CBUUID为180D
            central.scanForPeripherals(withServices: [heartRateServiceUUID])
        @unknown default:
            print("来自未来的错误")
        }
    }

    //MARK: 中心设备扫描外设并连接
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //如果想连接某外设时，需要对该外设进行全局变量，做一个强引用，系统才会把peripheral分配给下面的钩子函数里面的peripheral参数
        heartRateperipheral = peripheral
        central.stopScan()              //发现外设后停止扫描，可省电
        central.connect(peripheral)     //连接成功后立即调用didConnect peripheral方法
    }

    //MARK: 外设自行寻找Service
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //即将要使用peripheral的delegate方法，所以先委托self
        peripheral.delegate = self
        //由连接成功的外设自己寻找设备，立即调用didDiscoverServices方法
        //[xx] —— 指定服务，若nil则扫描所有服务（费电不推荐）
        peripheral.discoverServices([heartRateServiceUUID])
    }

    //连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
    }

    //连接断开
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral)         //重新连接外设
    }
}


//MARK: 外设设备协议
extension TestBluetoothViewController: CBPeripheralDelegate{
    
    //已发现服务（或发现失败）
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("没找到服务，原因是\(error.localizedDescription)")
        }
        guard let service = peripheral.services?.first else {return}
        //寻找特征，立即调用didDiscoverCharacteristicsFor方法
        peripheral.discoverCharacteristics([controlPointCharacteristicUUID,sensorLocationCharacteristicUUID,measurementCharacteristicUUID], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("没找到特征，原因是\(error.localizedDescription)")
        }
        guard let characteristics = service.characteristics else{return}
            for characteristic in characteristics{
                //向外设写入数据，调用didWriteValueFor characteristic方法
                if characteristic.properties.contains(.write){
                    peripheral.writeValue("100".data(using: .utf8)!, for: characteristic, type: .withResponse)
                    controlPointCharacteristic = characteristic
                }
                
                if characteristic.properties.contains(.read){
                    //读取外设数据（即读取外设某个特征值value），立即调用didUpdateValueFor characteristic方法
                    //若读取成功，通过characteristi.value取出值
                    //适合读取静态值
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify){
                    //订阅外设数据（即订阅外设某个特征值value），达到实时更新数据的目的
                    //订阅后先调用didUpdateNotificationStateFor characteristic
                    //若订阅成功，每当特征值变化时（true），调用didUpdateValueFor characteristic方法
                    //适合读取动态值
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                //这里可以继续发现特征下面的描述—— 也可不做for循环而单独指定某个特征
                //peripheral.didDiscoverDescriptorsFor characteristic
                //之后立即调用didDiscoverDescriptorsFor，可在里面获取描述值
            }
    }

    //写入时指定type为withResponse时会调用—— 写入成功与否的反馈
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("写入失败，原因是\(error.localizedDescription)")
            return
        }
        print("写入成功")
    }
    
    //订阅状态
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("订阅失败，原因是\(error.localizedDescription)")
            return
        }
    }
    
    //特征值已更新—— 1.读取特征值时调用 2.订阅特征值成功后，每当这个值变化时都会调用
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("读取失败，原因是\(error.localizedDescription)")
            return
        }

        //1.读取成功 2.订阅成功后值发生变化时，执行以下代码
        switch characteristic.uuid{
        case sensorLocationCharacteristicUUID:
            sensorLocationL.text =  String(data: characteristic.value!, encoding: .utf8)
        case measurementCharacteristicUUID:
//            heartRateL.text = String(data: characteristic.value!, encoding: .utf8)
            //LightBlue虚拟外设默认Hex形式，为方便调试，对数据进行处理从而显示utf8
            guard let heartRate = Int(String(data: characteristic.value!, encoding: .utf8)!) else{return}
            heartRateL.text = "\(heartRate)"
        default:
            break
        }

    }

}
