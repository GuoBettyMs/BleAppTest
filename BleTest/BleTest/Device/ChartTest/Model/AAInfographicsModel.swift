//
//  AAInfographicsModel.swift
//  IOSApp
//
//  Created by isdt on 2022/4/7.
//

import Foundation
import UIKit

class AAInfographicsModel {

    var startTaskBtnSelected = false
    var plotX = 0.0
    var index = -1
    var curveBackgroundColor = "#f2f2f2"
    var taskID = -1

    let shareFileName = "DataLog"
    var recordDataInfoArray: [RecordDataInfo] = []

    
    struct RecordDataInfo {
        var taskTime = -1
        var times: [String] = []
        var voltages: [Double] = []
        var currents: [Double] = []
        var powers: [Double] = []
        var currentCurve: [Double] = []
        var voltageCurve: [Double] = []
        var powerCurve: [Double] = []
        var timesPoint: [String] = []
        var currentsPoint: [Double] = []
        var voltagesPoint: [Double] = []
        var powersPoint: [Double] = []
        var multiple = 60
        var shareBool = false
        var pointBool = false
//        var multipleBool = false
        var curveValuesBool = false
        var maxPower = 0.0

    }
    

    
    init() {
        initData()
    }
    

    
    
    func initData() {

//        workingStatusList.removeAll()
        recordDataInfoArray.removeAll()
        taskID = -1
//        mDCStatus = -1
//        mDCVoltage = -1
//        mDCCurrent = -1
//        mDCMaximumPower = -1
//        mDCCurrentPower = -1
        index = -1
        recordDataInfoArray.append(RecordDataInfo())
        
//        for _ in 0...4 {
//            workingStatusList.append(WorkingStatusModel())
//        }

//        for _ in 0...3 {
//            recordDataInfoArray.append(RecordDataInfo())
//        }
    }
    
    func recordDataInfo(_ i: Int) {
        recordDataInfoArray[i].multiple = 60
        recordDataInfoArray[i].taskTime = -1
        recordDataInfoArray[i].curveValuesBool = false
//        recordDataInfoArray[i].multipleBool = false
        recordDataInfoArray[i].pointBool = false
        recordDataInfoArray[i].shareBool = false
        recordDataInfoArray[i].maxPower = 0.0
        recordDataInfoArray[i].times.removeAll()
        recordDataInfoArray[i].voltages.removeAll()
        recordDataInfoArray[i].currents.removeAll()
        recordDataInfoArray[i].powers.removeAll()
        recordDataInfoArray[i].currentCurve.removeAll()
        recordDataInfoArray[i].voltageCurve.removeAll()
        recordDataInfoArray[i].powerCurve.removeAll()
        recordDataInfoArray[i].powersPoint.removeAll()
        recordDataInfoArray[i].timesPoint.removeAll()
        recordDataInfoArray[i].voltagesPoint.removeAll()
        recordDataInfoArray[i].currentsPoint.removeAll()

    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> String {
        return String(format: "%.2d:%.2d:%.2d", (seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    

    func generateXlsx(name: String, data: RecordDataInfo) -> Bool {
        
        let fileName = name
//        switch channel {
//        case 0:
//            fileName = "USB_A_DataLog.xlsx"
//        case 1:
//            fileName = "USB_C1_DataLog.xlsx"
//        case 2:
//            fileName = "USB_C1_DataLog.xlsx"
//        case 3:
//            fileName = "USB_C1_DataLog.xlsx"
//
//        default:
//            fileName = "Null"
//        }
        
        /**
         ???????????????"\t" (Tab???,?????????????????????,????????????????????????
         1??????"\t"????????????????????????????????????
         2?????????????????????"\t"???????????????"\n"???
         3?????????????????????xls????????????
         **/
        var xlsDataMuArr: [String] = []
        // ???????????????
        xlsDataMuArr.append("-- \(fileName) --")
        xlsDataMuArr.append("")
        xlsDataMuArr.append("")
        xlsDataMuArr.append("")
        
        // ???????????????
        xlsDataMuArr.append("Time")
        xlsDataMuArr.append("Vbus(V)")
        xlsDataMuArr.append("Ibus(A)")
        xlsDataMuArr.append("Power(W)")
        
        for i in 0..<data.times.count {
            xlsDataMuArr.append(data.times[i])
            xlsDataMuArr.append("\(data.voltages[i])")
            xlsDataMuArr.append("\(data.currents[i])")
            xlsDataMuArr.append("\(data.powers[i])")

        }
        
        // ?????????????????????????????????????????? \t????????????????????????tab??????
        let fileContent = xlsDataMuArr.joined(separator: "\t")
        // ????????????????????????????????????????????????????????????
        var muStr = fileContent
        // ???????????????????????????????????????????????????\t????????????????????????\n???
        var subMuArr: [AnyHashable] = []
        for i in 0..<muStr.count {
            let range = (muStr as NSString).range(of: "\t", options: .backwards, range: NSRange(location: i, length: 1))
            if range.length == 1 {
                subMuArr.append(NSNumber(value: range.location))
            }
        }
        
        // ????????????\t
        for i in 0..<subMuArr.count {
            if i > 0 && (i % 4 == 0) {
                if let subRange = Range<String.Index>(NSRange(location: (subMuArr[i - 1] as? NSNumber)!.intValue, length: 1), in: muStr) { muStr.replaceSubrange(subRange, with: "\n") }
            }
        }
        
        // ???????????????
        let fileManager = FileManager()
        //??????UTF16??????????????????
        let fileData = muStr.data(using: .utf16)

        // ????????????
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName).path

        // ??????xls??????
        return fileManager.createFile(atPath: filePath, contents: fileData, attributes: nil)
   
    }
    
    func addPointData(_ i: Int,_ time: String,_ outputVoltage: Double,_ outputCurrent: Double,_ power: Double) {
        
        recordDataInfoArray[i].timesPoint.append(time)
        recordDataInfoArray[i].voltagesPoint.append(outputVoltage)
        recordDataInfoArray[i].currentsPoint.append(outputCurrent)
        recordDataInfoArray[i].powersPoint.append(power.decimal(1))
        
        //?????????????????????????????????????????????????????????????????????????????????????????????voltageCurve???currentCurve????????????????????????voltage???current????????????
        recordDataInfoArray[i].voltageCurve.append(outputVoltage * 5)
        recordDataInfoArray[i].currentCurve.append(outputCurrent * 27.7272)

        
        if recordDataInfoArray[i].powers.count != 0 {
            if power > recordDataInfoArray[i].powers.max()!+3{
                
                let multiple = 150.0/(power+3)
                var value: [Double] = []
                for powerValue in recordDataInfoArray[i].powers {
                    value.append(powerValue * multiple)
                }
                recordDataInfoArray[i].curveValuesBool = true
                recordDataInfoArray[i].powerCurve.append(power * multiple)
            }else {
                if recordDataInfoArray[i].powers.count > 4 {
                    if power > recordDataInfoArray[i].powers[recordDataInfoArray[i].powers.count - 4] && power > recordDataInfoArray[i].maxPower {
                        recordDataInfoArray[i].maxPower = power
                        let multiple = 150.0/(power+3)
                        var value: [Double] = []
                        for power in recordDataInfoArray[i].powers {
                            value.append(power * multiple)
                        }
                        recordDataInfoArray[i].curveValuesBool = true
                        recordDataInfoArray[i].powerCurve = value
                    }else {
                        let multiple = 150.0/(recordDataInfoArray[i].powers.max()!+3)
                        recordDataInfoArray[i].powerCurve.append(power * multiple)
                    }
                }else {
                    let multiple = 150.0/(recordDataInfoArray[i].powers.max()!+3)
                    recordDataInfoArray[i].powerCurve.append(power * multiple)
                }
                
            }
        }
        
    }
    
    
}
