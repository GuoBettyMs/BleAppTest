//
//  UserInfoManager.swift
//  IOSApp
//
//  Created by gbt on 2022/7/15.
//

import UIKit

//将用户的设置信息本地持久化
class MusicUserInfoManager: NSObject {

    // MARK: 获取用户的音频设置状态
    class func getAudioState() -> Bool{
        let isOn = UserDefaults.standard.string(forKey: "audioKey")
        if let on = isOn{
            if on == "on"{
                return true
            }else{
                return false
            }
        }
        return true
    }
    
    // MARK: 存储用户音频设置状态
    class func setAudioState(isOn: Bool){
        if isOn{
            UserDefaults.standard.set("on", forKey: "audioKey")
        }else{
            UserDefaults.standard.set("off", forKey: "audioKey")
        }
        UserDefaults.standard.synchronize()
        
    }
}
