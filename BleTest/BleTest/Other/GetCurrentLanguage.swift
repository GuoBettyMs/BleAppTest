//
//  GetCurrentLanguage.swift
//  IOSApp
//
//  Created by gbt on 2022/5/12.
//

import Foundation

func GetCurrentLanguage() -> String {

    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return "en"//英文
    case "zh-Hans-US","zh-Hans":
        return "cn"//中文
    default:
        return "en"
    }
}
