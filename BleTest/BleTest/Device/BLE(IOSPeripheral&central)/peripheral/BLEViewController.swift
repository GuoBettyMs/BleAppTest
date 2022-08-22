//
//  BLEViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/4/29.
//
//IOS 蓝牙外设
//若蓝牙外设断连后重新连接，而与之交互的中心设备不断连，则中心设备无法识别旧的外设，中心设备无法正常工作只能重新启动
//1.创建外设管理器——立即调用peripheralManagerDidUpdateState（外设协议）
//2.创建Service 和 Characteristic，在终端输入命令“uuidgen”获取CBUUID
//3.把特征加到服务里去，把服务加到外设管理器中去——立即调用didAdd service
//4.开始广播某服务——立即调用DidStartAdvertising，连接中心设备后，等待中心设备的指令
//5.当中心设备发送写入请求，调用didReceiveWrite request，外设将文本框中的值赋于request.value，传给中心设备
//6.当中心设备发送读取请求，调用didReceiveRead request，外设将文本框中的值赋于request.value，传给中心设备
//7.当中心设备订阅了某个特征值时，调用didSubscribeTo characteristic

import UIKit
import CoreBluetooth

class BLEViewController: UIViewController {
    
    let serviceUUID = CBUUID(string: "D5BE176D-046C-41D8-805E-FE18ED810E43")
    let writeUUID =  CBUUID(string: "983FDBCF-1A91-4EEA-B9BD-A286C0E57005")
    let readUUID =  CBUUID(string: "1CB71F67-8556-4D12-930B-277C7C4CA232")
    let notifyUUID =  CBUUID(string: "D4D31C5B-2B88-4B5F-9AD7-8DBC2450A1B6")

    @IBOutlet weak var writeL: UILabel!
    @IBOutlet weak var readL: UILabel!
    @IBOutlet weak var notifyL: UILabel!
    
    var peripheralManager: CBPeripheralManager!
    var writeCharacteristic: CBMutableCharacteristic!
    var notifyCharacteristic: CBMutableCharacteristic!

    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //创建外设管理器——立即调用peripheralManagerDidUpdateState
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)

    }

    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}



extension BLEViewController: CBPeripheralManagerDelegate{
    //确保本外设支持蓝牙低能耗（BLE）并开启时才继续操作
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state{
        case .unknown:
            print("未知状态")
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
            //创建Service 和 Characteristic
            //主要服务——从心率监测仪获得的心率数据，次要服务——从心率监测仪获得的电量数据
            let service = CBMutableService(type: serviceUUID, primary: true)
            
            //properties 和permissions 可多个（写成数组）
            //value 为了可动态修改，写nil
            writeCharacteristic = CBMutableCharacteristic(type: writeUUID, properties: .write, value: nil, permissions: .writeable)
            let readCharacteristic = CBMutableCharacteristic(type: readUUID, properties: .read, value: nil, permissions: .readable)
            notifyCharacteristic = CBMutableCharacteristic(type: notifyUUID, properties: .notify, value: nil, permissions: .readable)
            
            //把特征加到服务里去
            service.characteristics = [writeCharacteristic, readCharacteristic, notifyCharacteristic]
            //把服务加到外设管理器中去——立即调用didAdd service
            peripheralManager.add(service)
            //开始广播某服务——立即调用DidStartAdvertising
            //一旦开始广播后，此外设能被中心设备发现，并被连接
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[serviceUUID]])      //开始广播
            
        @unknown default:
            print("来自未来的错误")
        }
    }
    
    //当在外设管理器中添加服务时
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("未找到服务，原因是\(error.localizedDescription)")
        }
    }
    
    //开始广播某服务，等待中心设备发号施令
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("无法开始广播，原因是\(error.localizedDescription)")
        }
    }
    
    //当中心设备发送（对一个或多个特征值的）写入请求时
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        let request = requests[0]
        if request.characteristic.properties.contains(.write){
            //给当前请求的特征改值
            writeCharacteristic.value = request.value
            //显示到视图
            writeL.text = String(data: request.value!, encoding: .utf8)
            //给中心设备反馈，以便中心设备可以触发一些delegate方法
            peripheral.respond(to: request, withResult: .success)
        }else{
            peripheral.respond(to: request, withResult: .writeNotPermitted)
        }
    }
    
    //当中心设备发送（某个特征值的）读取请求时
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.properties.contains(.read){
            //给request 下的value赋当时请求特征的值（即文本框中的数据），然后随着respond带到中心设备去
            request.value = readL.text!.data(using: .utf8)
            peripheral.respond(to: request, withResult: .success)
        }else{
            peripheral.respond(to: request, withResult: .readNotPermitted)
        }
    }
    
    //当中心设备订阅了某个特征值时
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        updateNotifyValue()
    }

    //当中心设备取消订阅某个特征值时
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        timer?.invalidate()
    }
    
    //传输队伍有了剩余空间时
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        updateNotifyValue()
    }
    
    func updateNotifyValue(){
        //用计时器模拟外设数据的实时变动
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){(timer) in

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日 HH时mm分ss秒"
            let dateStr = dateFormatter.string(from: Date())
            
            self.notifyL.text = dateStr     //也同时实时显示到外设上来，方便演示
            
            //更新特征值，给一个或多个订阅了这个特征的中心设备发送实时数据
            //返回bool，true-> 发送成功
            //若传输队伍中有了空间，调用peripheralManagerIsReady,可在里面再次发送数据
            self.peripheralManager.updateValue(dateStr.data(using: .utf8)!, for: self.notifyCharacteristic, onSubscribedCentrals: nil)
        }
    }
    
}

