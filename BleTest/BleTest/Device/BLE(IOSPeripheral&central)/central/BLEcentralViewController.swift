//
//  BLEcentralViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/5/4.
//
//IOS 蓝牙中心设备
//只要与中心设备交互的蓝牙外设不断连，中心设备退出后重新连接，会自动刷新数据正常工作

import UIKit
import CoreBluetooth

let serviceUUID = CBUUID(string: "D5BE176D-046C-41D8-805E-FE18ED810E43")
let writeUUID =  CBUUID(string: "983FDBCF-1A91-4EEA-B9BD-A286C0E57005")
let readUUID =  CBUUID(string: "1CB71F67-8556-4D12-930B-277C7C4CA232")
let notifyUUID =  CBUUID(string: "D4D31C5B-2B88-4B5F-9AD7-8DBC2450A1B6")


class BLEcentralViewController: UIViewController {

    @IBOutlet weak var writeTextField: UITextField!
    @IBOutlet weak var readL: UILabel!
    @IBOutlet weak var notifyL: UILabel!
    
    var centralManager: CBCentralManager!
    var fuxinperipheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //MARK: 手动给外设发射数据
    @IBAction func write(_ sender: Any) {
        guard let writeCharacteristic = writeCharacteristic else{return}
        fuxinperipheral!.writeValue(writeTextField.text!.data(using: .utf8)!, for: writeCharacteristic, type: .withResponse)
    }
    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }
    

}

extension BLEcentralViewController: CBCentralManagerDelegate{

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

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
            central.scanForPeripherals(withServices: [serviceUUID])
        @unknown default:
            print("来自未来的错误")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //如果想连接某外设时，需要对该外设进行全局变量，做一个强引用，系统才会把peripheral分配给下面的钩子函数里面的peripheral参数
        fuxinperipheral = peripheral
        central.stopScan()              //发现外设后停止扫描，可省电
        central.connect(peripheral)     //连接成功后立即调用didConnect peripheral方法
    }
    
    //连接断开的钩子函数
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.connect(peripheral)         //重新连接外设
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //即将要使用peripheral的delegate方法，所以先委托self
        peripheral.delegate = self
        //由连接成功的外设自己寻找设备，立即调用didDiscoverServices方法
        //[xx] —— 指定服务，若nil则扫描所有服务（费电不推荐）
        peripheral.discoverServices([serviceUUID])
    }
    
}

extension BLEcentralViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("没找到服务，原因是\(error.localizedDescription)")
        }
        guard let service = peripheral.services?.first else {return}
        //寻找特征，立即调用didDiscoverCharacteristicsFor方法
        peripheral.discoverCharacteristics([writeUUID,readUUID,notifyUUID], for: service)
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
                    writeCharacteristic = characteristic
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
        case readUUID:
            readL.text =  String(data: characteristic.value!, encoding: .utf8)
        case notifyUUID:
            notifyL.text = String(data: characteristic.value!, encoding: .utf8)
        default:
            break
        }

    }
    
    
}
