//
//  App.swift
//  IOSApp
//
//  Created by gbt on 2022/5/6.
//

import Foundation
import UIKit

func AppUpdate(){
    
    //Bundle.main.object，返回与接收者信息属性列表中指定键 CFBundleShortVersionString关联的值
    let LOCAL_VERSION:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    let path = NSString(format: "http://itunes.apple.com/cn/lookup?id=1568620244") as String
    let url = URL(string: path)
    let request = NSMutableURLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
   
    
    request.httpMethod = "POST"
    //加载URL请求的数据，并在请求完成或失败时分别处理相对应的程序块
    NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue()) { (response, data, error) in
        
        let receiveStatusDic = NSMutableDictionary()
        var storeVersion = ""
        var storeReleaseNotes = ""
        if data != nil {
            do {
                //将json数据转成NSDictionary
                let dic:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                if let resultCount = dic["resultCount"] as? NSNumber {
                    if resultCount.intValue > 0 {
                        
                        if let arr = dic["results"] as? NSArray {
                            if let dict = arr.firstObject as? NSDictionary {
                                if let version = dict["version"] as? String {
                                    storeVersion = version
                                }
                                
                                if let releaseNotes = dict["releaseNotes"] as? String {
                                    storeReleaseNotes = releaseNotes
                                }
                            }
                            if LOCAL_VERSION.compare(storeVersion) == .orderedAscending {
                                
                                DispatchQueue.main.async{
                                    
                                    let alertView = UIAlertController.init(title: NSLocalizedString("SoftwareUpdate", comment: "SoftwareUpdate"), message: storeReleaseNotes, preferredStyle: .alert)
                                    
                                    let alert = UIAlertAction.init(title: NSLocalizedString("Update", comment: "Update"), style: .destructive) { (UIAlertAction) in
                                        
                                        UIApplication.shared.open(URL(string:"itms-apps://itunes.apple.com/cn/app/xing-rui-yu-le/id1568620244?mt=8")!)
                                    }
                                    let cancleAlert = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (UIAlertAction) in
                                        
                                    }
                                    alertView.addAction(cancleAlert)
                                    
                                    alertView.addAction(alert)
                                    
                                    UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }catch _ {
                receiveStatusDic.setValue("0", forKey: "status")
            }
        }else {
            receiveStatusDic.setValue("0", forKey: "status")
        }
    }
}
