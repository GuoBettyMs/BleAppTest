//
//  TestTableView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/24.
//

import UIKit
import CoreBluetooth
import RxSwift

class TesttableView: UIView, UITableViewDelegate, UITableViewDataSource{


    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tabView: UITableView!
    var testViewController:UIViewController? = nil
    var scanCellsModelList = [AppIconModel]()
    
    private var deviceAddWorkItem: DispatchWorkItem?
    private var disposeBag = DisposeBag()
    let mBleMessage = BleMessage.sharedInstance
    var deviceAddTimer:Int = 0
    var bindOk = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        Bundle.main.loadNibNamed("TestTableView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        tabView.delegate = self
        tabView.dataSource = self
        
        tabView.tableFooterView = UIView()
        tabView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tabView.rowHeight = 100
        
        
        let nib = UINib(nibName: "TestTableViewCell", bundle: nil)
        tabView.register(nib, forCellReuseIdentifier: "TestTableViewCellIdentifier")

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanCellsModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TestTableViewCell! = tabView.dequeueReusableCell(withIdentifier: "TestTableViewCellIdentifier") as? TestTableViewCell
        
        cell.titlenameL.text = scanCellsModelList[indexPath.row].titlename
        cell.visittimeL.text = Product.NAME[scanCellsModelList[indexPath.row].product]
        cell.detailL.text = scanCellsModelList[indexPath.row].detail
        cell.searchL.text = scanCellsModelList[indexPath.row].type
        cell.imgView.image = Product.LOGO[scanCellsModelList[indexPath.row].product]!
        
        return cell
    }
    
    // MARK: 列表点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertBinding = AlertBinding.init(frame: CGRect.init(x: 0, y: 0, width: testViewController!.view.frame.width, height: testViewController!.view.frame.height))
        alertBinding.imgView.image = Product.SCANLOGO[scanCellsModelList[indexPath.row].product]!
        alertBinding.backgroundColor = UIColor.init(named: "Main_Gray60")
        alertBinding.titleLabel.text = Product.SCANHINT[scanCellsModelList[indexPath.row].product]!
        testViewController!.view.addSubview(alertBinding)
        
        alertBinding.confirmButton.rx.tap
            .subscribe(onNext: { [self] in
                if deviceAddWorkItem != nil {
                    deviceAddWorkItem!.cancel()
                    deviceAddWorkItem = nil
                }
                mBleMessage.startScanDeviceData()
                alertBinding.removeFromSuperview()
                
            }).disposed(by: disposeBag)
        
        var bind = false
        let startTime = Date().secondTime
        bindOk = false
        deviceAddTimer = 0
        
        PackBase.clearPacks()
        
//        let bindingAction = scanCellsModelList[indexPath.row].scanPacketAnalysis.bindingAction

        //添加蓝牙外设
        let myBluetoothDevice = MyBluetoothDevice(cBPeripheral: scanCellsModelList[indexPath.row].peripheral!)
        
        mBleMessage.scanDeviceTypealias = { [self]
            (_ peripheral: CBPeripheral, _ broadcastPacketAnalysis: BroadcastPacketAnalysis, _ scanPacketAnalysis: ScanPacketAnalysis)->() in
            
//            Logger.debug("scanCellsModelList: \(scanCellsModelList.count)")
            if scanCellsModelList.count != 0 && scanCellsModelList[indexPath.row].peripheral == peripheral {
                
//                Logger.debug("rssi:   \(bindingAction) + \(scanPacketAnalysis.bindingAction) +  \(broadcastPacketAnalysis.rssi)")
//                if scanPacketAnalysis.bindingAction != scanCellsModelList[indexPath.row].scanPacketAnalysis.bindingAction
//                || Int(truncating: broadcastPacketAnalysis.rssi) > Product.SCANRSSI[scanCellsModelList[indexPath.row].product]! && Int(truncating: broadcastPacketAnalysis.rssi) != 0{
                if scanPacketAnalysis.bindingAction != scanCellsModelList[indexPath.row].scanPacketAnalysis.bindingAction
                || Int(truncating: broadcastPacketAnalysis.rssi) > -100 && Int(truncating: broadcastPacketAnalysis.rssi) != 0{
                    if !bind {
                        bind = true
                        mBleMessage.stopScanDevice()
                        mBleMessage.setCurrentDevice(currentDeviceScan: myBluetoothDevice)
                        mBleMessage.startCommConn()
                    }
                }
            }
        }
        
        Logger.debug("device add \(scanCellsModelList[indexPath.row].type)")
        
        deviceAddWorkItem = DispatchWorkItem { [self] in
            
            let outTime = Date().secondTime - startTime
            if bind {
                var packBaseReadListTmp:[PackBase] = []
//                print("\(mBleMessage.bleDo(packBaseWrite: nil, packBaseReadList: &packBaseReadListTmp))")
                
               if mBleMessage.bleDo(packBaseWrite: nil, packBaseReadList: &packBaseReadListTmp) == .COMMUNICATION {
                       bindOk = true
                       deviceAddTimer = 0
               }
            }
            if outTime > 30 {
               alertBinding.titleLabel.text = NSLocalizedString("BindingFailure", comment: "BindingFailure")
                
               if mBleMessage.isConnection {
                   mBleMessage.disconnectDevice()
               }
               mBleMessage.startScanDeviceData()
                
               DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                   alertBinding.removeFromSuperview()
               })
            } else {
               if bindOk {
                   if mBleMessage.isConnection {
                       mBleMessage.disconnectDevice()
                   }
                   kSettings.currentDevice = scanCellsModelList[indexPath.row].identifier
                   let scanDbManager = ScanDbManager()
                   scanDbManager.insert(scanDbModel: scanCellsModelList[indexPath.row])
                   alertBinding.titleLabel.text = NSLocalizedString("BindingSuccess", comment: "BindingSuccess")
                   
//                   print("\(scanCellsModelList[indexPath.row]))")
//                   print("\(scanDbManager.query())")
                   
                   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                       alertBinding.removeFromSuperview()
                       self.testViewController!.dismiss(animated: true, completion: nil)
                   })
               } else {
                   //倒计时
                   alertBinding.timeLabel.text = "\(30 - outTime)S"
                   DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: deviceAddWorkItem!)
               }
            }

        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: deviceAddWorkItem!)
        
    }
    
}
