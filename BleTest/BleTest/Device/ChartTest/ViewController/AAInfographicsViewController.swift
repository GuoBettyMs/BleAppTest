//
//  AAInfographicsViewController.swift
//  IOSApp
//
//  Created by isdt on 2022/3/28.
//
/*
    为了使系统自带的十字架校准线无法去除，需更改第三方库以下文件
 AAOptions\ AATooltip\ AAStyle\ AASeriesElement\ AAChartModel\ AAChartView\ AAAxis
 \AADataLabels \AALabels
 文件夹 Resources -> AAJSFiles: AAChartView\ AAeasing\ AAFunnel\ AAhighcharts\ AAHighchartsMore\ AARounded-Corners
 
 */


import UIKit
import AAInfographics
import RxSwift
import RxCocoa

class AAInfographicsViewController:  BaseobjectViewController<AAInfographicsView>  {

    private var disposeBag = DisposeBag()
    private let model = AAInfographicsModel()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        container.chartView.delegate = self as AAChartViewDelegate
        model.taskID = 0

        container.taskStatusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let selfs = self else{
                    return
                }
                if !selfs.model.startTaskBtnSelected{
                    selfs.model.startTaskBtnSelected = true
                    selfs.startTask(0)
                }else{
                    selfs.model.startTaskBtnSelected = false
                    selfs.container.taskStatusButton.setImage(UIImage(named: "Start"), for: .normal)
                    selfs.container.shareButton.setImage(UIImage(named: "Share"), for: .normal)
                    
                    selfs.timer?.invalidate()
                    selfs.timer = nil
                    
                    if (selfs.model.recordDataInfoArray[0].shareBool) {
                        selfs.startTask(0)
                    }else {
                        let alertController = UIAlertController.init(title: NSLocalizedString("NoShareHint", comment: "NoShareHint"), message: "", preferredStyle: .alert)
                        let startAction = UIAlertAction(title: NSLocalizedString("StartNewRecord", comment: "StartNewRecord"), style: .default, handler: { alert -> Void in
                            self!.startTask(0)
                        })
                        
                        let saveAction = UIAlertAction(title: NSLocalizedString("SaveNow", comment: "SaveNow"), style: .cancel, handler: { alert -> Void in
                            selfs.shareRecord()
                        })
                        alertController.addAction(startAction)
                        alertController.addAction(saveAction)
                        selfs.present(alertController, animated: true)
                    }
                }
            }).disposed(by: disposeBag)
        container.shareButton.addTarget(self, action: #selector(shareRecord), for: .touchUpInside)
    }

    @objc func shareRecord(){
        let alertController = UIAlertController(title: NSLocalizedString("FileName", comment: "FileName"), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField: UITextField!)->Void in
            textField.text = self.model.shareFileName
        })
        let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .default, handler: { alert -> Void in
            let fileName = "\(alertController.textFields![0].text!.trimmingCharacters(in: .whitespacesAndNewlines)).csv"
            if self.model.generateXlsx(name: fileName, data: self.model.recordDataInfoArray[0]) {
                
                let controller = UIActivityViewController(activityItems: [FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)], applicationActivities: nil)
                
//                    let pop = controller.popoverPresentationController
//                    pop?.sourceView = self.view
//                    pop?.sourceRect = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2, width: 0, height: 0)
//
//                    self.present(controller, animated: true, completion: nil)

                self.showDetailViewController(controller, sender: nil)
                controller.completionWithItemsHandler = {(type, completed, items, error) in
                    if completed {
                        Logger.debug("分享成功")
                        self.model.recordDataInfoArray[0].shareBool = true
                    }else {
                        Logger.debug("分享失败")
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: { alert -> Void in
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //开始曲线任务
    private func startTask(_ channel: Int) {
        container.removelineView()
        model.index = -1
        model.recordDataInfoArray[channel].shareBool = false
        container.shareButton.setImage(UIImage(named: "ShareNull"), for: .normal)
        container.taskStatusButton.setImage(UIImage(named: "Stop"), for: .normal)
        model.recordDataInfo(channel)
        updateCurveValues()

        self.timer = Timer.scheduledTimer(timeInterval: 1,
                                           target: self,
                                           selector: #selector(self.chartData),
                                           userInfo: 0,
                                           repeats: true)
        self.timer?.fire()

    }
    
    func updateCurveValues(){
        container.chartModel
           .backgroundColor(model.curveBackgroundColor)
           .colorsTheme(["#ff2a7f99","#5599ff99","#9933FF99"])//主题颜色数组
           .series([
                AASeriesElement()
                    .name(NSLocalizedString("Voltage", comment: "Voltage"))
                    .data(model.recordDataInfoArray[model.taskID].voltageCurve)
                    .lineWidth(2.5)
                ,
                AASeriesElement()
                    .name(NSLocalizedString("Current", comment: "Current"))
                    .data(model.recordDataInfoArray[model.taskID].currentCurve)
                    .lineWidth(2.5)
                ,
                AASeriesElement()
                    .name(NSLocalizedString("Power", comment: "Power"))
                    .data(model.recordDataInfoArray[model.taskID].powerCurve)
                    .lineWidth(2.5)
           ])
       container.chartView.aa_refreshChartWholeContentWithChartModel(container.chartModel)
    }
    
    // MARK: 更新曲线数据
    @objc private func chartData(_ timer: Timer) {
        let i = timer.userInfo as! Int
//        Logger.debug("chartDataA\(String(describing: i))")

        model.recordDataInfoArray[0].taskTime += 1
//        Logger.debug("chartDataC1 \(model.secondsToHoursMinutesSeconds(seconds: model.recordDataInfoArray[0].taskTime))")
        
        
        let outputVoltage = (Double(Int.random(in: 17000..<17500)) / 1000.0).decimal(1)
        let outputCurrent = (Double(Int.random(in: 2500..<3000)) / 1000.0).decimal(1)
        let power = outputVoltage * outputCurrent
        let time = model.secondsToHoursMinutesSeconds(seconds: model.recordDataInfoArray[0].taskTime)

        model.recordDataInfoArray[0].times.append(time)
        model.recordDataInfoArray[0].voltages.append(outputVoltage)
        model.recordDataInfoArray[0].currents.append(outputCurrent)
        model.recordDataInfoArray[0].powers.append(power.decimal(1))

        model.addPointData(0, time, outputVoltage, outputCurrent, power)
        updateCurveView(0)
    }

    // MARK: 更新曲线
    private func updateCurveView(_ i: Int) {

        if model.taskID == i {
            if !model.recordDataInfoArray[i].curveValuesBool {
                let voltageSeriesElement = AASeriesElement().name(NSLocalizedString("Voltage", comment: "Voltage"))
                    .data(model.recordDataInfoArray[i].voltageCurve)
                let currentCurveSeriesElement = AASeriesElement().name(NSLocalizedString("Current", comment: "Current"))
                    .data(model.recordDataInfoArray[i].currentCurve)
                let powerCurveSeriesElement = AASeriesElement().name(NSLocalizedString("power", comment: "power"))
                    .data(model.recordDataInfoArray[i].powerCurve)

                container.timeLabel.text = model.secondsToHoursMinutesSeconds(seconds: model.recordDataInfoArray[i].taskTime)
                container.chartView.aa_onlyRefreshTheChartDataWithChartModelSeries([voltageSeriesElement, currentCurveSeriesElement, powerCurveSeriesElement])
            }else {
                model.recordDataInfoArray[i].curveValuesBool = false
                updateCurveValues()
            }
        }
        
        if model.index != -1 {
            let a =  Double((Int(UIScreen.main.bounds.width)-35-24))/Double(model.recordDataInfoArray[i].powerCurve.count-1)

            model.plotX = Double(model.index) * a
            Logger.debug("aaaaaaa: \(a)  plotX: \(model.plotX) index: \(model.index)")
            
            UIView.animate(withDuration: 0.7, animations: {
                self.container.curvelineView.transform = CGAffineTransform(translationX: CGFloat(self.model.plotX), y: 0)
            })
        }
 
        
        if model.recordDataInfoArray[i].pointBool {
            model.recordDataInfoArray[i].pointBool = false
            model.index = -1
            container.removelineView()
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
        
    }
    
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - 暗黑模式监听
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    
                    model.curveBackgroundColor = "#262626"
                    //暗黑模式
                    Logger.debug("暗黑模式")
                    if model.taskID != -1 {
                        container.chartModel.backgroundColor(model.curveBackgroundColor)
                            .series([
                                AASeriesElement()
                                    .name(NSLocalizedString("Voltage", comment: "Voltage"))
                                    .data(model.recordDataInfoArray[model.taskID].voltageCurve)
                                    .lineWidth(2.5)
                                ,
                                AASeriesElement()
                                    .name(NSLocalizedString("Current", comment: "Current"))
                                    .data(model.recordDataInfoArray[model.taskID].currentCurve)
                                    .lineWidth(2.5)
                                ,
                                AASeriesElement()
                                    .name(NSLocalizedString("Power", comment: "Power"))
                                    .data(model.recordDataInfoArray[model.taskID].powerCurve)
                                    .lineWidth(2.5)
                            ])
                        
                        container.chartView.aa_refreshChartWholeContentWithChartModel(container.chartModel)
                    }
                    
                }else{
                    model.curveBackgroundColor = "#f2f2f2"
                    //明亮模式
                    Logger.debug("明亮模式")
                    if model.taskID != -1 {
                        container.chartModel.backgroundColor(model.curveBackgroundColor)
                            .series([
                                AASeriesElement()
                                    .name(NSLocalizedString("Voltage", comment: "Voltage"))
                                    .data(model.recordDataInfoArray[model.taskID].voltageCurve)
                                    .lineWidth(2.5)
                                ,
                                AASeriesElement()
                                    .name(NSLocalizedString("Current", comment: "Current"))
                                    .data(model.recordDataInfoArray[model.taskID].currentCurve)
                                    .lineWidth(2.5)
                                ,
                                AASeriesElement()
                                    .name(NSLocalizedString("Power", comment: "Power"))
                                    .data(model.recordDataInfoArray[model.taskID].powerCurve)
                                    .lineWidth(2.5)
                            ])
                        
                        container.chartView.aa_refreshChartWholeContentWithChartModel(container.chartModel)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}


// MARK: - 实现对 AAChartView 事件代理的监听
extension AAInfographicsViewController: AAChartViewDelegate {
  open func aaChartView(_ aaChartView: AAChartView, moveOverEventMessage: AAMoveOverEventMessageModel) {
      
      //curvelineView 所在view 与曲线所在view 不是同一个
      //curvelineView 的起点是plotX，它的原点是curvelineView 所在view的原点，曲线所在view的原点是横坐标为0的点
      model.plotX = (moveOverEventMessage.offset!["plotX"] as? Double)! + 7
      model.index = moveOverEventMessage.index!
      print("🔥selected point series element name: \(moveOverEventMessage.name ?? "")   \(model.plotX)")

      container.curvelineView.transform = CGAffineTransform(translationX: CGFloat(model.plotX), y: 0)
      if model.index != -1 {
          container.curveTimeLabel.text =  model.recordDataInfoArray[model.taskID].timesPoint[model.index]
      }

      
      container.voltageCurrentPowerLabel.text =
      "\((model.recordDataInfoArray[model.taskID].voltagesPoint[model.index]).decimal(0))V / \( (model.recordDataInfoArray[model.taskID].currentsPoint[model.index]).decimal(0))A / \((model.recordDataInfoArray[model.taskID].powersPoint[model.index]).decimal(0))W"
      
      model.recordDataInfoArray[model.taskID].pointBool = true

  }
}
