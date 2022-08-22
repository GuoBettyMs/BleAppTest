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
         字符串插入"\t" (Tab键,制表键的简写）,达到换列的作用。
         1、用"\t"把数据数组拼接成字符串；
         2、把每行末尾的"\t"改成换行符"\n"；
         3、生成后缀名为xls的文件。
         **/
        var xlsDataMuArr: [String] = []
        // 第一行内容
        xlsDataMuArr.append("-- \(fileName) --")
        xlsDataMuArr.append("")
        xlsDataMuArr.append("")
        xlsDataMuArr.append("")
        
        // 第二行内容
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
        
        // 把数组拼接成字符串，连接符是 \t（功能同键盘上的tab键）
        let fileContent = xlsDataMuArr.joined(separator: "\t")
        // 字符串转换为可变字符串，方便改变某些字符
        var muStr = fileContent
        // 新建一个可变数组，存储每行最后一个\t的下标（以便改为\n）
        var subMuArr: [AnyHashable] = []
        for i in 0..<muStr.count {
            let range = (muStr as NSString).range(of: "\t", options: .backwards, range: NSRange(location: i, length: 1))
            if range.length == 1 {
                subMuArr.append(NSNumber(value: range.location))
            }
        }
        
        // 替换末尾\t
        for i in 0..<subMuArr.count {
            if i > 0 && (i % 4 == 0) {
                if let subRange = Range<String.Index>(NSRange(location: (subMuArr[i - 1] as? NSNumber)!.intValue, length: 1), in: muStr) { muStr.replaceSubrange(subRange, with: "\n") }
            }
        }
        
        // 文件管理器
        let fileManager = FileManager()
        //使用UTF16才能显示汉字
        let fileData = muStr.data(using: .utf16)

        // 文件路径
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName).path

        // 生成xls文件
        return fileManager.createFile(atPath: filePath, contents: fileData, attributes: nil)
   
    }
    
    func addPointData(_ i: Int,_ time: String,_ outputVoltage: Double,_ outputCurrent: Double,_ power: Double) {
        
        recordDataInfoArray[i].timesPoint.append(time)
        recordDataInfoArray[i].voltagesPoint.append(outputVoltage)
        recordDataInfoArray[i].currentsPoint.append(outputCurrent)
        recordDataInfoArray[i].powersPoint.append(power.decimal(1))
        
        //由于三条线的数值范围不同，为了使曲线图的坡度明显，加大曲线图的voltageCurve、currentCurve的数值，但实际值voltage、current是不变的
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
