//
//  ScanPacketAnalysis.swift
//  IOSApp
//
//  Created by gbt on 2022/5/9.
//
//  外设浏览包

import Foundation

class ScanPacketAnalysis: NSObject{
        
        var dataString = ""
        var manufacturerID = ""
        var device = ""
        var state = "O"
        var bindingAction = ""
        var cH1Charged = ""
        var cH2Charged = ""

        init (dataString: String) {
//            Logger.debug("dataString:\(dataString) +  \(dataString.count)")
            if dataString.count < 13 {
                super.init()
                return
            }else {
                device = dataString[4..<12].trimmingCharacters(in: .whitespaces)
                state = dataString[12]
                if (dataString.count > 13) {
                    bindingAction = dataString[13,2]
                }
                if (device == "PS200L") {
                    bindingAction = dataString[13,5]
                }
//                if device == "NP2Air" {
//                    cH1Charged = dataString[15,3]
//                    cH2Charged = dataString[17,3]
//                }
//                if device == "LP2Air" {
//                    cH1Charged = dataString[15,3]
//                    cH2Charged = dataString[17,3]
//                }
                
//                Logger.debug("state   \(state)")
                super.init()
            }
            
        }
        
}
