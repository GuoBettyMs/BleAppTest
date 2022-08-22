//
//  DownloadFirmware.swift
//  IOSApp
//
//  Created by gbt on 2022/5/13.
//

import Foundation
import SwiftyJSON
import Alamofire

class Downloader {
    
    static let sharedInstance = Downloader()
    
    var upgradeMode: UpgradeMode?
    static let LOCAL_FIRMWARE_NAME = "Firmware.fwd"
    static let BLE_FIRMWARE_NAME = "BLE.zip"
    static let LOCAL_BLE_A = "BLE_A.hex"
    static let LOCAL_BLE_B = "BLE_B.hex"
    static let FIRMWARE_DOWNLOAD_LIST = "https://www.isdt.co/down/firmwares/firmwareDownloadList.json"
    static let FIRMWARE_DOWNLOADDEMO_LIST = "https://www.isdt.co/down/firmwaresDemo/firmwareDownloadDemoList.json"
    static let BLE_FIRMWARE_DOWNLOAD_LIST = "https://www.isdt.co/down/ble/Ble_OTA.json"
    static let BLE_FIRMWARE_DOWNLOADDEMO_LIST = "https://www.isdt.co/down/ble/Ble_OTA_Demo.json"
    
    
    typealias FirmwareDownloadClbk = (_ upgradeMode: UpgradeMode)->()
    typealias FirmwareUpgradeClbk = (_ firmwarePath: URL?)->()
    
    private init() {
        
        upgradeMode = nil
    }
    
    func getUpgradeMode() -> UpgradeMode? {
        return upgradeMode
    }
    
    func download(fwdUrl: String, upgradeClbk: FirmwareUpgradeClbk?) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(Downloader.LOCAL_FIRMWARE_NAME)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let urlString = URLRequest(url: URL(string:fwdUrl)!)
        
        AF.download(urlString, to: destination).response { response in
            print(response)
            Logger.debug("response:\(response)")
            if response.error == nil {
                // let image = UIImage(contentsOfFile: imagePath)
                //                Logger.debug("path: " + (response.destinationURL?.path ?? "pathNull"))
                upgradeClbk?(response.fileURL)
            } else {
                upgradeClbk?(nil)
            }
        }
    }
    
    //BleUpgradeHandle.swift(393)
    func downloadBle(fwdUrl: String, upgradeClbk: FirmwareUpgradeClbk?, type: String) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(type)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let urlString = URLRequest(url: URL(string:fwdUrl)!)
        
        AF.download(urlString, to: destination).response { response in
            print(response)
            Logger.debug("response:\(response)")
            if response.error == nil {
                // let image = UIImage(contentsOfFile: imagePath)
                //                Logger.debug("path: " + (response.destinationURL?.path ?? "pathNull"))
                upgradeClbk?(response.fileURL)
            } else {
                upgradeClbk?(nil)
            }
        }
    }
    
    //DeviceView.swift(393)
    func downloadInfoUpdate(uri: String, clbk: FirmwareDownloadClbk?, model: String) -> Bool{
        var ret = false
        upgradeMode = UpgradeMode()
        URLCache.shared.removeAllCachedResponses()
        let headers:HTTPHeaders = ["Cache-Control":"no-store"]
        let method:HTTPMethod = HTTPMethod(rawValue: "GET")
        AF.request(uri, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate().responseJSON { [self] response in
            switch response.result {
            case let .success(value):
                let json = JSON(value)
                for index in 0..<json["downloadList"].count {
                    if json["downloadList",index,"model"].string! == model {
                        //self.deviceName = json["downloadList",index,"deviceName"].string!
                        upgradeMode!.information = json["downloadList",index,"information"].string!
                        upgradeMode!.informationEn = json["downloadList",index,"informationEn"].string!
                        upgradeMode!.url = json["downloadList",index,"firmwareUrl"].string!
                        upgradeMode!.version = json["downloadList",index,"versionNumber"].string!
                    }
                }
                if upgradeMode!.version != "" {
                    clbk?(upgradeMode!)
                }
                ret = true
            case let .failure(error):
                ret = false
                print(error)
            }
        }
        return ret
    }
    
    //DeviceView.swift(401)
    func downloadBleInfoUpdate(uri: String, name: String, model: String, clbk: FirmwareDownloadClbk?) -> Bool{
        var ret = false
        upgradeMode = UpgradeMode()
        URLCache.shared.removeAllCachedResponses()
        let headers:HTTPHeaders = ["Cache-Control":"no-store"]
        let method:HTTPMethod = HTTPMethod(rawValue: "GET")
        AF.request(uri, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).validate().responseJSON { [self] response in
            switch response.result {
            case let .success(value):
                let json = JSON(value)
                for index in 0..<json["downloadList"].count {
                    if json["downloadList",index,"model"].string! == model && json["downloadList",index,"deviceName"].string! == name{
                        //self.deviceName = json["downloadList",index,"deviceName"].string!
                        upgradeMode!.information = json["downloadList",index,"information"].string!
                        upgradeMode!.informationEn = json["downloadList",index,"informationEn"].string!
                        upgradeMode!.url = json["downloadList",index,"firmwareUrl"].string!
                        upgradeMode!.version = json["downloadList",index,"versionNumber"].string!
                    }
                }
                if upgradeMode!.version != "" {
                    clbk?(upgradeMode!)
                }
                ret = true
            case let .failure(error):
                ret = false
                print(error)
            }
        }
        return ret
    }
    
    
}
