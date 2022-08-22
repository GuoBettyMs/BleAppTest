//
//  DeviceView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/24.
//

import UIKit
import NVActivityIndicatorView

class DeviceView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scanDbModelList.count
    }
    
    // MARK: 加载列表
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:DeviceCollectionViewCell! = devicecollectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCollectionViewCell", for: indexPath) as? DeviceCollectionViewCell

        let scanDbModel = scanDbModelList[indexPath.row]
        let type = Product.types(scanDbModel.type)
        //        cell.imgView.image = Product.LOGO[type]!
        
        cell.imgnameL.text = scanDbModel.titlename
        cell.imgView.image = ProductImg().titleImg(scanDbModel.titlename)

        
        //若进行过外设的改名，则数据库也发生了更新，只有当外设在线时，才能读取数据库，更新列表名称
        if scanDbModel.offlineBool {

            let name = scanDbModel.broadcastPacketAnalysis.name
            cell.imgnameL.text = name
            cell.statusL.text = NSLocalizedString("Standby", comment: "Standby")
            cell.statusL.textColor = UIColor.init(named: "CellLColor1")
            if name == "\0\0\0\0\0\0\0\0\0\0\0\0\0\0" {
                cell.imgnameL.text = scanDbModel.titlename
            }
        }else {
            
            cell.statusL.text = NSLocalizedString("OffLine", comment: "OffLine")
            cell.statusL.textColor = UIColor.init(named: "OrangeColor")
        }
        
        switch scanDbModel.scanPacketAnalysis.state {
        case "O":
            cell.statusL.text = NSLocalizedString("OffLine", comment: "OffLine")
            cell.statusL.textColor = UIColor.init(named: "OrangeColor")
            
        case "S":
            cell.statusL.text = NSLocalizedString("Standby", comment: "Standby")
            cell.statusL.textColor = UIColor.init(named: "CellLColor1")
            
        case "C":
            cell.statusL.text = NSLocalizedString("Charging", comment: "Charging")
            cell.statusL.textColor = UIColor.init(named: "CellLColor1")
            
        case "D":
            cell.statusL.text = NSLocalizedString("DisCharging", comment: "DisCharging")
            cell.statusL.textColor = UIColor.init(named: "CellLColor1")
            
        case "F":
            cell.statusL.text = NSLocalizedString("Complete", comment: "Complete")
            cell.statusL.textColor = UIColor.init(named: "CellLColor1")
            
        case "E":
            cell.statusL.text = NSLocalizedString("Error", comment: "Error")
            cell.statusL.textColor = UIColor.init(named: "DestroyRoundBG")
            
        default:
            break

        }

        return cell
    }
    
    // MARK: 列表点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Logger.debug("列表点击\(indexPath.row)")

        var rootViewController: UINavigationController?
        switch scanDbModelList[indexPath.row].type {
        case "calculator":
            let sb = UIStoryboard(name: "CalculatorStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "CalculatorViewControllerID") as! CalculatorViewController
            destination.cellDataAction = scanDbModelList[indexPath.row]
            rootViewController = UINavigationController(rootViewController: destination)
        case "emittertest":
            let sb = UIStoryboard(name: "EmittertestStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "EmittertestViewControllerID") as! EmittertestViewController
            destination.cellDataAction = scanDbModelList[indexPath.row]
            rootViewController = UINavigationController(rootViewController: destination)
        case "aAInfographics":
            let sb = UIStoryboard(name: "AAInfographicsStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "AAInfographicsViewControllerID") as! AAInfographicsViewController
            destination.cellDataAction = scanDbModelList[indexPath.row]
            rootViewController = UINavigationController(rootViewController: destination)
        case "testCollection":
            let sb = UIStoryboard(name: "TestCollectiooViewFlowLayoutStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "TestCollectionViewControllerID") as! TestCollectionViewController
            rootViewController = UINavigationController(rootViewController: destination)
        case "testBluetooth":
            let sb = UIStoryboard(name: "TestBluetoothStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "TestBluetoothViewControllerID") as! TestBluetoothViewController
            rootViewController = UINavigationController(rootViewController: destination)
        case "bleCentral":
            let sb = UIStoryboard(name: "BLEcentralStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "BLEcentralViewControllerID") as! BLEcentralViewController
            rootViewController = UINavigationController(rootViewController: destination)
        case "blePeripheral":
            let sb = UIStoryboard(name: "BLEViewControllerStoryboard", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "BLEViewControllerID") as! BLEViewController
            rootViewController = UINavigationController(rootViewController: destination)
//        case "jsonPasing":
//            let destination =  JsonPasingViewController()
//            rootViewController = UINavigationController(rootViewController: destination)
        case "MenuTable":
            let sb = UIStoryboard(name: "MenuMainTableView", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "MenuTableVCID") as! MenuTableVC
            rootViewController = UINavigationController(rootViewController: destination)
        case "RecordBook":
            let sb = UIStoryboard(name: "RecordBook", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "RecordBookVCID") as! RecordBookVC
            rootViewController = UINavigationController(rootViewController: destination)
        case "WKWeb":
            let sb = UIStoryboard(name: "WKWebView", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "WKWebViewVCID") as! WKWebViewVC
            rootViewController = UINavigationController(rootViewController: destination)
        default:
            return
        }
        rootViewController!.modalPresentationStyle = .fullScreen
        deviceViewController!.present(rootViewController!, animated: true, completion: nil)
        
//        if scanDbModelList[indexPath.row].offlineBool {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: true)
//
//            var rootViewController: UINavigationController?
//            switch scanDbModelList[indexPath.row].type {
//            case "01080000", "81080000":
//                let sb = UIStoryboard(name: "CalculatorStoryboard", bundle: nil)
//                let destination = sb.instantiateViewController(withIdentifier: "CalculatorViewControllerID") as! CalculatorViewController
//                destination.cellDataAction = scanDbModelList[indexPath.row]
//                rootViewController = UINavigationController(rootViewController: destination)
//            default:
//                return
//            }
//            rootViewController!.modalPresentationStyle = .fullScreen
//            deviceViewController!.present(rootViewController!, animated: true, completion: nil)
//
//        }
        
        
    }
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var devicecollectionView: UICollectionView!
    var collectionViewLayout = DeviceFlowLayout()
    lazy var deviceViewController: UIViewController? = nil
    lazy var scanDbModelList = [AppIconModel]()
    lazy var cellDataAction: AppIconModel? = nil
    let scanDbManager = ScanDbManager()
    lazy var bottommenuView: BottommenuVIew? = nil
    var settingSendChecker:(()->()) = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadViewFromNib()
    
    }
    
    
    func loadViewFromNib() {
        
        Bundle.main.loadNibNamed("DeviceView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        devicecollectionView.collectionViewLayout = collectionViewLayout
        devicecollectionView.dataSource = self
        devicecollectionView.delegate = self
        devicecollectionView.register(UINib(nibName: "DeviceCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeviceCollectionViewCell")

        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longpressGestureRecognizer.minimumPressDuration = 0.5
        longpressGestureRecognizer.delegate = self
        longpressGestureRecognizer.delaysTouchesBegan = true
        self.devicecollectionView.addGestureRecognizer(longpressGestureRecognizer)

    }
    
    //手势长按方法
    @objc func handleLongPress(gestureRecognizier: UILongPressGestureRecognizer) {
        if gestureRecognizier.state != .began {
            return
        }
        let row = gestureRecognizier.location(in: self.devicecollectionView)
        guard let indexPath = self.devicecollectionView.indexPathForItem(at: row) else {
            return
        }
        
        bottommenuView = BottommenuVIew.init(frame: CGRect.init(x: 0, y: 0, width: deviceViewController!.view.bounds.width, height:  deviceViewController!.view.bounds.height))
        deviceViewController?.view.addSubview(bottommenuView!)

        cellDataAction = scanDbModelList[indexPath.row]
        bottommenuView!.movetopView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveTopAction)))
        bottommenuView!.removeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeAction)))
        bottommenuView!.upgradeView
            .addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upgradeAction)))
        bottommenuView!.changenameV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(renameAction)))
            
    }
    
    //MARK: 置顶app
    @objc func moveTopAction() {
        bottommenuView?.dismiss()
        
        //列表更新了顺序，为确保重新刷新后顺序不变，数据库更新元素排序：先删除选中的元素，再添加（数据库已默认倒序添加元素）
        scanDbManager.delete(identifiers: cellDataAction!.identifier)
        scanDbManager.insert(scanDbModel: cellDataAction!)
        
        //若列表中第一位的titlename与cellDataAction!.titlename 相同，则删除
        scanDbModelList.removeAll{ $0.identifier == cellDataAction!.identifier}
        //在第一位添加 cellDataAction
        scanDbModelList.insert(cellDataAction!, at: 0)

        devicecollectionView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeIndentifier"), object: cellDataAction!.identifier)

    }
    
    //MARK: 删除app
    @objc func removeAction() {
        bottommenuView?.dismiss()
        //数据库删除
        scanDbManager.delete(identifiers: cellDataAction!.identifier)
        
        //若列表中第一位的titlename与cellDataAction!.titlename 相同，则删除
        scanDbModelList.removeAll{ $0.identifier == cellDataAction!.identifier}
        devicecollectionView.reloadData()
        
        //数据库自行更新，令通知中心NotificationCenter，传播信息："removeIndentifier"
        //func post(name: NSNotification.Name, object: Any?) 创建具有给定名称和发件人的通知，并将其发布到通知中心。
        //通知名称：removeIndentifier ；发送通知的对象： cellDataAction!.identifier
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeIndentifier"), object: cellDataAction!.identifier)
    }
    
    //MARK: 改名app
    @objc func renameAction() {
        
        bottommenuView?.dismiss()

        let mBleMessage = BleMessage.sharedInstance
        let alertController = UIAlertController(title: NSLocalizedString("Rename", comment: "Rename"), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { [self] (textField: UITextField!)->Void in
            if cellDataAction!.broadcastPacketAnalysis.name != "" && cellDataAction!.titlename != cellDataAction!.broadcastPacketAnalysis.name{
                let names = cellDataAction!.broadcastPacketAnalysis.name.replacingOccurrences(of: "\0", with: "")
//                Logger.debug("names:\(names)")
                textField.text = names
            }else {
                let names = cellDataAction!.titlename.trimmingCharacters(in: .whitespacesAndNewlines)
//                Logger.debug("names:\(names)")
                textField.text = names
            }

        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: {alert -> Void in
        })
        let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .cancel, handler: { [self]  alert -> Void in
            let name = alertController.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if nil == name || name!.isEmpty {
                Alert.alert(title: NSLocalizedString("NotEmpty", comment: "NotEmpty"), controllerV: deviceViewController!)
                
            } else if [UInt8](name!.utf8).count > 14 {
                Alert.alert(title: NSLocalizedString("LengthExceedsLimit", comment: "LengthExceedsLimit"), controllerV: deviceViewController!)
            } else {

                PackBase.clearPacks()
                let myBluetoothDevice = MyBluetoothDevice(cBPeripheral: cellDataAction!.peripheral!)

                mBleMessage.setCurrentDevice(currentDeviceScan: myBluetoothDevice)
                mBleMessage.startCommConn()

                let renameReq = RenameReq()
                renameReq.setName(name: name!)
                mBleMessage.named = false
                mBleMessage.putPackBaseUserList(packBase: renameReq)

                var packBaseReadList:[PackBase] = []

                let packBaseTmp = mBleMessage.getNextPack()
                let _ = mBleMessage.bleDo(packBaseWrite: packBaseTmp, packBaseReadList: &packBaseReadList)
                
                let bindingAlert = UIAlertController.init(title: NSLocalizedString("Setting", comment: "Setting"), message: nil, preferredStyle: .alert)
                let activityIndicatorV =  NVActivityIndicatorView(frame: CGRect(x: 205.0, y: 17.0, width: 30.0, height: 30.0), type: .ballRotateChase, color: UIColor.init(named: "CellLColor"), padding: nil)
                bindingAlert.view.addSubview(activityIndicatorV)
                activityIndicatorV.startAnimating()
                deviceViewController?.present(bindingAlert, animated: true)

                var settingSendTimer = 0
                self.settingSendChecker = { [self] in
                    settingSendTimer += 1
                    let _ = mBleMessage.bleDo(packBaseWrite: packBaseTmp, packBaseReadList: &packBaseReadList)

                    if settingSendTimer > 10 {
                        activityIndicatorV.stopAnimating()
                        bindingAlert.title = NSLocalizedString("SetTimeout", comment: "SetTimeout")
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            bindingAlert.dismiss(animated: true, completion: nil)
                        })
                        
                        mBleMessage.disconnectDevice()
                        mBleMessage.clearPackCmdBaseUserList()
                        mBleMessage.startScanDeviceData()
                        
                    } else {
                        
                        if mBleMessage.named && mBleMessage.nameOk {
                            //更新cell 标题
                            scanDbManager.updateData(identifierU: cellDataAction!.identifier, nameU: name!)

                            activityIndicatorV.stopAnimating()
                            bindingAlert.title = NSLocalizedString("SetSuccessfully", comment: "SetSuccessfully")
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                bindingAlert.dismiss(animated: true, completion: nil)
                            })
                            
                        //刷新，显示新修改的名称
                        mBleMessage.disconnectDevice()
                        mBleMessage.clearPackCmdBaseUserList()
                        mBleMessage.startScanDeviceData()
                            
                        }else if mBleMessage.named && !mBleMessage.nameOk{
                          
                            activityIndicatorV.stopAnimating()
                            bindingAlert.title = NSLocalizedString("SettingFailed", comment: "SettingFailed")
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                                bindingAlert.dismiss(animated: true, completion: nil)
                            })
                        mBleMessage.disconnectDevice()
                        mBleMessage.clearPackCmdBaseUserList()
                        mBleMessage.startScanDeviceData()
                            
                            
                        }else {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: self.settingSendChecker)
                        }
                        
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: self.settingSendChecker)

               
            }
        })

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        deviceViewController!.present(alertController, animated: true, completion: nil)

    }
    
    //MARK: 升级app
    @objc func upgradeAction() {

        bottommenuView?.dismiss()

        if cellDataAction!.offlineBool{
            let otaOld = false

            let mBleMessage = BleMessage.sharedInstance

            let type = Product.types(cellDataAction!.type)
            let value = "\(Product.TYPE_NAME[type]!)"
            let donwloadClbk:((_ upgradeMode: UpgradeMode)->())? = { [self]
                (_ upgradeMode: UpgradeMode)->() in

                var updateFlag = true
                let versions = upgradeMode.version

                #if DEBUG
                updateFlag = true
                #endif

                if updateFlag {

                    let langguage = GetCurrentLanguage()
                    var message = ""
                    if langguage == "cn" {
                        message = upgradeMode.information
                    } else {
                        message = upgradeMode.informationEn
                    }

                    let alertController = UIAlertController.init(title: NSLocalizedString("UpgradeFirmware", comment: "UpgradeFirmware"), message: "", preferredStyle: .alert)
                    let messageAtt = NSMutableAttributedString(string: "(->\(versions))\r\n"+message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)])
                    alertController.setValue(messageAtt, forKey: "attributedMessage")


                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: { [self] alert -> Void in

                        Alert.alert(title: NSLocalizedString("UpGrade Failed", comment: "UpGrade Failed"), controllerV: deviceViewController!)
                    })

                    let confirmAction = UIAlertAction(title: NSLocalizedString("Upgrade", comment: "Upgrade"), style: .cancel, handler: { [self] alert -> Void in

                        let myBluetoothDevice = MyBluetoothDevice(cBPeripheral: self.cellDataAction!.peripheral!)

                        if value != "NP2Air" && value != "LP2Air" && value != "C4Air" && value != "Power200" {

                            //分析硬件类型
                            let firmwareAnalysis = FirmwareAnalysis(upgradeMode: upgradeMode, myDevice: myBluetoothDevice)
    //
                            let upgradeClbk = {
                                (_ path: URL?)->() in

                                if nil == path {
                                    //upgradeDialog.hud?.hide(animated: true)
                                    return
                                }

                                let analysisBool = firmwareAnalysis.loadFirmware(fileUrl: path)

                                Logger.debug("analysisBool\(analysisBool)")
                                if analysisBool {
                                    firmwareAnalysis.firmwareAnalysisViewController = self.deviceViewController
                                    let name = Product.NAME[type]! + " - " + self.cellDataAction!.titlename

                                    if otaOld {
    //                                    K4UpgradeHandle.upgradeHandle(firmwareAnalysis: firmwareAnalysis, name: name, connectionStatus: true)
                                    }else {
                                        UpgradeHandle.upgradeHandle(firmwareAnalysis: firmwareAnalysis, name: name, connectionStatus: false)
                                    }

                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: true)
                                }

                            }
                            firmwareAnalysis.upgradeClbk = upgradeClbk
                            firmwareAnalysis.show()

                        }else {
                            
                            let bleFirmwareAnalysis = BleFirmwareAnalysis(bleUpgradeMode: upgradeMode, myDevice: myBluetoothDevice)
                            
                            if value == "C4Air" || value != "Power200" {
                                bleFirmwareAnalysis.addMultiple = 16
                            }
                            
                            bleFirmwareAnalysis.type = kBleA
                            let upgradeClbk = {
                                (_ path: URL?)->() in
                                
                                if nil == path {
                                    //upgradeDialog.hud?.hide(animated: true)
                                    return
                                }
                                
                                let analysisBool = bleFirmwareAnalysis.loadFirmware(fileUrl: path)
                                
                                Logger.debug("analysisBool\(analysisBool)")
                                if analysisBool {
                                    bleFirmwareAnalysis.bleFirmwareAnalysisViewController = self.deviceViewController
                                    let name = Product.NAME[type]! + " - " + self.cellDataAction!.titlename
                                    
                                    if self.cellDataAction!.type == "81050000" || self.cellDataAction!.type == "81060000" || value == "C4Air" || value != "Power200" {
                                        mBleMessage.upgradeBool = true
                                        bleFirmwareAnalysis.upgradeState = .UPGRADE
                                    }else {
                                        
                                        let bootModeRequest = OTAUpgradeCmdReq()
                                        mBleMessage.putPackBaseUserList(packBase: bootModeRequest)
                                        mBleMessage.bootState = false
                                        bleFirmwareAnalysis.upgradeState = .CONNECT
                                    
                                    }
                                    mBleMessage.setCurrentDevice(currentDeviceScan: MyBluetoothDevice(cBPeripheral: self.cellDataAction!.peripheral!))
                                    mBleMessage.startCommConn()
                                    bleFirmwareAnalysis.bleFirmwareAnalysisViewController = self.deviceViewController
                                    BleUpgradeHandle.upgradeHandle(firmwareAnalysis: bleFirmwareAnalysis, name: name, internalBool: true)
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationThread"), object: true)
                                } else {
                                    
                                }

                            }
                            bleFirmwareAnalysis.upgradeClbk = upgradeClbk
                            bleFirmwareAnalysis.show()
                        }
                    })

                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    deviceViewController!.present(alertController, animated: true)
                } else {

                    Alert.alert(title: NSLocalizedString("YourFirmwareIsUpToDate", comment: "YourFirmwareIsUpToDate"), controllerV: deviceViewController!)
                }
            }
            #if DEBUG
    
            if value != "NP2Air" && value != "LP2Air" && value != "C4Air" && value != "Power200" {
                let _ = Downloader.sharedInstance.downloadInfoUpdate(uri: kChargerOTADemo, clbk: donwloadClbk, model: "\(Product.TYPE_NAME[type]!)")
            }else {
                let _ = Downloader.sharedInstance.downloadBleInfoUpdate(uri: kBleOTADemo, name: "\(Product.TYPE_NAME[type]!)", model: "A", clbk: donwloadClbk)
            }
    
            #else
    
            if value != "NP2Air" && value != "LP2Air" && value != "C4Air" && value != "Power200" {
                let _ = Downloader.sharedInstance.downloadInfoUpdate(uri: kChargerOTA, clbk: donwloadClbk, model: "\(Product.TYPE_NAME[type]!)")
            }else {
                Downloader.sharedInstance.downloadBleInfoUpdate(uri: kBleOTA, name: "\(Product.TYPE_NAME[type]!)", model: "A", clbk: donwloadClbk)
            }
    
            #endif
            Logger.debug("donwloader")

        }
        
        
  
    }
        

    

    
        

}
