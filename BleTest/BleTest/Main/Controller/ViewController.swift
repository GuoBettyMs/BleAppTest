//
//  ViewController.swift
//  IOSApp
//
//  Created by isdt on 2022/3/7.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var deviceView: DeviceView!
    var scanDbModelList = [AppIconModel]()
    let scanDbManager = ScanDbManager()
    
    let mBleMessage = BleMessage.sharedInstance
    var loopEnd:Bool = false

    let settings = Settings.sharedInstance
    var comparedScanModelList = [AppIconModel]()
    var lineScanModelList = [AppIconModel]()
    
    @IBOutlet weak var musicButton: UIButton!
    var spinner: UIActivityIndicatorView!
    
    var scanDispatchWorkItem: DispatchWorkItem?
    let SCAN_INTERVAL: DispatchTimeInterval = DispatchTimeInterval.milliseconds(60000)
    var offlineDispatchWorkItem: DispatchWorkItem?
    let OFFLINE_INTERVAL: DispatchTimeInterval = DispatchTimeInterval.milliseconds(10000)

    
    
/***            视图加载完毕后调用，在该方法中进行自定义视图的加载                **/
    override func viewDidLoad() {
        super.viewDidLoad()

        //数据库增加App，type 为视图名称，identifier为视图控制器名称
        let RecordBookVC = AppIconModel(type: "RecordBook", titlename: "RecordBook", identifier: "RecordBook", peripheral: nil, product: Product.types(""), broadcastPacketAnalysis:  BroadcastPacketAnalysis.init(bytes: nil), scanPacketAnalysis: ScanPacketAnalysis.init(dataString: ""), offlineBool: false, visitime: "", detail: "", searchtime: "")
        
//        scanDbManager.insert(scanDbModel: aAInfographicsVC)
//        scanDbManager.insert(scanDbModel: RecordBookVC)
        
//        scanDbManager.delete(identifiers: "WKWebView")          //删除 identifier

//        let List = scanDbManager.query()
//        print(List)
        
        mBleMessage.scanDeviceTypealias = nil
        deviceView.deviceViewController = self
        
        
        // MARK: 载入动画
        let viewMoveInAnimation = CATransition()
        viewMoveInAnimation.duration = 1.5
        viewMoveInAnimation.type = .moveIn
        viewMoveInAnimation.subtype = .fromTop
        deviceView.layer.add(viewMoveInAnimation, forKey: "viewMoveInAnimation")

        updateUI()
        
        //读取用户的音频设置状态
        if MusicUserInfoManager.getAudioState(){
           musicButton.setTitle("音效：开", for: .normal)
           MusicEngine.shareInstance.playBackgroundMusic()
        }else{
           musicButton.setTitle("音效：关", for: .normal)
           MusicEngine.shareInstance.stopBackgroundMusic()
        }
        
        
        /***           设置主页面左滑右滑的手势，以及添加显示新界面的方法               **/
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)
        
        let screen1 = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen1.edges = .left
        view.addGestureRecognizer(screen1)

        //创建调用通知的选择器，收到传播信息notificationThread时（当名称为notificationThread ），调用方法notificationThread
        NotificationCenter.default.addObserver(self, selector: #selector(notificationThread), name:NSNotification.Name(rawValue: "notificationThread"),object: nil)
        
        //创建调用通知的选择器，收到传播信息removeIndentifier时（当名称为removeIndentifier ），调用方法removeIndentifier
        NotificationCenter.default.addObserver(self, selector: #selector(removeIndentifier), name:NSNotification.Name(rawValue: "removeIndentifier"),object: nil)
        
        let defaultStand = UserDefaults.standard
        let showOffline = defaultStand.string(forKey: UDKeys.ListInfo.showOffline)

        //显示离线设备
        if showOffline == nil {
            defaultStand.set(true, forKey: UDKeys.ListInfo.showOffline)
            defaultStand.set(false, forKey: UDKeys.ListInfo.sortByName)
            defaultStand.synchronize()
        }

        settings.showOfflineBool = defaultStand.bool(forKey: UDKeys.ListInfo.showOffline)
        settings.sortByNameBool = defaultStand.bool(forKey: UDKeys.ListInfo.sortByName)

        settings.addObserver(self, forKeyPath: "showOfflineBool", options: .new, context: nil)
        settings.addObserver(self, forKeyPath: "sortByNameBool", options: .new, context: nil)

    }
    
    // MARK: 加载菊花动画
    func setSpinner(){
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
//        spinner.backgroundColor = .gray
        spinner.layer.cornerRadius = 10
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: deviceView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: deviceView.centerYAnchor).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 80).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        spinner.startAnimating()
    }

    
    // MARK: 监听删除更新数据
    @objc func removeIndentifier(obj: NSNotification){
        
        scanDbModelList = deviceView.scanDbModelList
        comparedScanModelList = deviceView.scanDbModelList
        lineScanModelList = deviceView.scanDbModelList
        //deviceCV.collectionView.reloadData()
        
    }
    
    // MARK: 监听设置值更新UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        //settings.removeObserver(self, forKeyPath: "showOfflineBool", context: nil)
        if keyPath == "showOfflineBool" {
            if !settings.showOfflineBool {
                lineScanModelList.removeAll()
                for data in scanDbModelList {
                    if data.offlineBool {
                        lineScanModelList.append(data)
                    }
                }
                if lineScanModelList.count == 0 {
//                    noDeviceL.isHidden = false
                }
                deviceView.scanDbModelList = lineScanModelList
                deviceView.devicecollectionView.reloadData()
            }else {
//                noDeviceL.isHidden = true
                deviceView.scanDbModelList = scanDbModelList
                deviceView.devicecollectionView.reloadData()
            }

        }else {
            if deviceView.scanDbModelList.count > 0 && settings.sortByNameBool {
                //                scanDbModelList = DataProcessing.sortName(modelList: deviceCV.scanDbModelList)
                //                lineScanModelList = scanDbModelList
                //                comparedScanModelList = scanDbModelList
                //                deviceCV.scanDbModelList = lineScanModelList
                //                deviceCV.collectionView.reloadData()
            }
        }

    }
    
    @objc func notificationThread(obj: NSNotification){
        let bool =  obj.object as! Bool
        if bool {
            mBleMessage.stopScanDevice()
            loopEnd = true
            offlineDispatchWorkItem?.cancel()
            scanDispatchWorkItem?.cancel()

        }else {

            loopEnd = false
            mBleMessage.startScanDeviceData()
            rescan()
            updateUI()
            offlineUpdateUI()
        }
    }
    
    /** viewcontroller上的视图已经显示在屏幕上才会被调用（视图只有使用了viewcontroller切换方法才会被显示）**/
    // MARK: 获取数据库数据
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.spinner.stopAnimating()             //关闭加载动画
        self.spinner.removeFromSuperview()
        
//        //载入动画
//        let viewMoveInAnimation = CATransition()
//        viewMoveInAnimation.duration = 1.5
//        viewMoveInAnimation.type = .moveIn
//        viewMoveInAnimation.subtype = .fromTop
//        deviceView.layer.add(viewMoveInAnimation, forKey: "viewMoveInAnimation")
        
        
        loopEnd = false
        scanDbModelList.removeAll()
        scanDbModelList = scanDbManager.query()
//        if scanDbModelList.count != 0 {
//            noDeviceL.isHidden = true
//        }
        
        deviceView.scanDbModelList.removeAll()
        deviceView.devicecollectionView.reloadData()
        
        for scanDbMode in scanDbModelList {
            if kSettings.currentDevice == scanDbMode.identifier {
                var new = scanDbMode
                new.scanPacketAnalysis.state = "S"
                new.offlineBool = true
                deviceView.scanDbModelList.append(new)
            }else {
                deviceView.scanDbModelList.append(scanDbMode)
            }
        }
        deviceView.devicecollectionView.reloadData()
        
        if scanDbModelList.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [self] in
                mBleMessage.startScanDeviceData()
                rescan()
                updateUI()
                offlineUpdateUI()
                
                if settings.sortByNameBool {
                    deviceView.scanDbModelList = DataProcessing.sortName(modelList: deviceView.scanDbModelList)
                    deviceView.devicecollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: 重新扫描
    func rescan() {
        
        scanDispatchWorkItem = DispatchWorkItem { [self] in
            
            if loopEnd {
                return
            }
            
            mBleMessage.stopScanDevice()
            mBleMessage.startScanDeviceData()
            
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + SCAN_INTERVAL, execute: scanDispatchWorkItem!)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + SCAN_INTERVAL, execute: scanDispatchWorkItem!)
        
    }
    
    func updateUI(){
        
            var startTime = Date().milliTime
            
            mBleMessage.scanDeviceTypealias = { [self]
                (_ peripheral: CBPeripheral, _ broadcastPacketAnalysis: BroadcastPacketAnalysis, _ scanPacketAnalysis: ScanPacketAnalysis)->() in
                
                let time = Date().milliTime
                
                var  i = 0
                while i < scanDbModelList.count {
//                    Logger.debug("地址：", "\(scanDbModelList[i].identifier) : \(peripheral.identifier.uuidString)")

                    if scanDbModelList[i].identifier == peripheral.identifier.uuidString {
                        scanDbModelList[i].broadcastPacketAnalysis = broadcastPacketAnalysis
                        scanDbModelList[i].scanPacketAnalysis = scanPacketAnalysis
                        scanDbModelList[i].offlineBool = true
                        scanDbModelList[i].peripheral = peripheral
                        
                        comparedScanModelList = DataProcessing.comparedData(scanDbModelList: scanDbModelList, comparedScanModelList: comparedScanModelList, i: i)
//                        print("\(comparedScanModelList)")
                        
                        if !settings.showOfflineBool {

                            lineScanModelList = DataProcessing.lineData(scanDbModelList: scanDbModelList, lineScanModelList: lineScanModelList, i: i, peripheral: peripheral, broadcastPacketAnalysis: broadcastPacketAnalysis)
                            deviceView.scanDbModelList = lineScanModelList
//                            print("\(lineScanModelList)")
                            
                            if (time - startTime) > 800 {
                                startTime = Date().milliTime
                                deviceView.devicecollectionView.reloadData()
                            }
                            return
                        }

                        break
                    }
                    i += 1
                }
            
                if settings.showOfflineBool {
                    deviceView.scanDbModelList = scanDbModelList
                    if (time - startTime) > 800 {
                        startTime = Date().milliTime
                        deviceView.devicecollectionView.reloadData()
                    }
                }
                
//                deviceView.scanDbModelList = scanDbModelList
//                if (time - startTime) > 800 {
//                    startTime = Date().milliTime
//                    deviceView.devicecollectionView.reloadData()
//                }
                
            }
    }
    
    // MARK: 判断是否在线
    func offlineUpdateUI() {
        
        offlineDispatchWorkItem = DispatchWorkItem { [self] in
            
            if loopEnd {
                return
            }
            
            var i = 0
            while scanDbModelList.count > 0 && i < comparedScanModelList.count {
                var compared = 0
                var comparedBool:Bool = false
                for j in 0..<scanDbModelList.count {
                    if comparedScanModelList[i].identifier == scanDbModelList[j].identifier {
                        break
                    }else {
                        compared = j
                        comparedBool = true
                    }
                }
                if comparedBool {
                    scanDbModelList[compared].offlineBool = false
                    scanDbModelList[compared].scanPacketAnalysis.state = "O"
                    
                    if !settings.showOfflineBool {
                        lineScanModelList.removeAll{$0.identifier == scanDbModelList[compared].identifier}
                    }
                }
                i += 1
            }
            
            if !settings.showOfflineBool {
                deviceView.scanDbModelList = lineScanModelList
                deviceView.devicecollectionView.reloadData()
                if comparedScanModelList.count == 0 {
                    lineScanModelList.removeAll()
                    deviceView.devicecollectionView.reloadData()
                }
            }
            
            if comparedScanModelList.count == 0 {
                for i in 0..<scanDbModelList.count {
                    scanDbModelList[i].offlineBool = false
                    scanDbModelList[i].scanPacketAnalysis.state = "O"
                }
                if settings.showOfflineBool {
                    deviceView.scanDbModelList = scanDbModelList
                    deviceView.devicecollectionView.reloadData()
                }
            }
//            Logger.debug("删除 comparedScanModelList")
            
            comparedScanModelList.removeAll()
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + OFFLINE_INTERVAL, execute: offlineDispatchWorkItem!)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + OFFLINE_INTERVAL, execute: offlineDispatchWorkItem!)
    }
    
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        let x = screenEdgePan.translation(in: view).x
        Logger.debug("点击了\(x)")
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: true)

        //从右往左滑
        if screenEdgePan.state == .ended {
            if x < -50 {
//                let sb = UIStoryboard(name: "BLEcentralStoryboard", bundle: nil)
//                let destination = sb.instantiateViewController(withIdentifier: "BLEcentralViewControllerID") as! BLEcentralViewController
//                let rootViewController = UINavigationController(rootViewController: destination)
//                rootViewController.modalPresentationStyle = .fullScreen
//                self.present(rootViewController, animated: true, completion: nil)
                
                let sb = UIStoryboard(name: "WKWebView", bundle: nil)
                let destination = sb.instantiateViewController(withIdentifier: "WKWebViewVCID")
                destination.modalPresentationStyle = .fullScreen
                self.present(destination, animated: true, completion: nil)
            }
        }
        
        //从左往右滑
        if screenEdgePan.state == .ended {
            if x > 50 {
            }
        }
           
    }

/** 会在UIViewController 实例被创建时调用，用于视图的构建加载**/
    override func loadView() {
        super.loadView()
        
        setSpinner()
    }
    
/** 将要布局子视图时调用  **/
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//    }
/** 已经布局子视图时调用  **/
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//    }
/** viewcontroller上的视图将要显示在屏幕上才会被调用（视图只有使用了viewcontroller切换方法才会被显示）**/
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    
    @IBAction func musicAction(_ sender: Any) {
        if MusicUserInfoManager.getAudioState(){
            musicButton.setTitle("音效：关", for: .normal)
            MusicUserInfoManager.setAudioState(isOn: false)
            MusicEngine.shareInstance.stopBackgroundMusic()
        }else{
            musicButton.setTitle("音效：开", for: .normal)
            MusicUserInfoManager.setAudioState(isOn: true)
            MusicEngine.shareInstance.playBackgroundMusic()
        }
    }
    
//* viewcontroller上的视图将要从屏幕上消失时被调用*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        MusicEngine.shareInstance.stopBackgroundMusic()
        offlineDispatchWorkItem?.cancel()
        scanDispatchWorkItem?.cancel()
        

    }
/** viewcontroller上的视图已经从屏幕上消失时被调用**/
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)

    }
}

