//
//  AAInfographicsView.swift
//  IOSApp
//
//  Created by isdt on 2022/4/7.
//

import UIKit
import AAInfographics
import SnapKit

class AAInfographicsView: UIView {

    @IBOutlet weak var infoView: UIView!
    let scrollView = UIScrollView()
    let contentView = UIView()

    let navigationView = UIView()
    let uSBStatusLabel = UILabel()
    let taskStatusButton = UIButton()
    let shareButton = UIButton()
    let curveView = UIView()
    var channel = -1
    private let voltageLabel = UILabel()
    private let currentLabel = UILabel()
    private let powerLable = UILabel()
    let timeLabel = UILabel()
    let curveInfoView = UIView()
    var chartModel = AAChartModel()
    let chartView = AAChartView()
    let curvelineView = UIView()
    
    var rectCorner:UIRectCorner = .allCorners
    
    let curveTimeLabel = UILabel()
    let voltageCurrentPowerLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    

    func setUp() {
        
        infoView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalTo(UIScreen.main.bounds.height*0.8)
            make.size.equalToSuperview()
        }

        contentView.addSubview(navigationView)
        navigationView.addSubview(uSBStatusLabel)
        navigationView.addSubview(taskStatusButton)
        navigationView.addSubview(shareButton)
        
        navigationView.snp.remakeConstraints { make in
            make.height.equalTo(60)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        taskStatusButton.setImage(UIImage(named: "Start"), for: .normal)
        uSBStatusLabel.snp.remakeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        uSBStatusLabel.text = "--"
        uSBStatusLabel.font = UIFont.systemFont(ofSize: 12)
        uSBStatusLabel.textColor = UIColor(named: "tintColor-1")

        shareButton.setImage(UIImage(named: "ShareNull"), for: .normal)
        shareButton.snp.remakeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
        shareButton.isHidden = false
        
        
        taskStatusButton.snp.remakeConstraints { make in
            make.right.equalTo(shareButton.snp.left).offset(-15)
            make.centerY.equalToSuperview()
        }
             
        
        contentView.addSubview(curveView)
        curveView.snp.remakeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(named: "LineColor")
        curveView.addSubview(lineView)
        lineView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        curveView.addSubview(curveInfoView)
        curveInfoView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
        }

        
        curveInfoView.addSubview(voltageLabel)
        curveInfoView.addSubview(currentLabel)
        curveInfoView.addSubview(powerLable)
        curveInfoView.addSubview(timeLabel)

        voltageLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        voltageLabel.font = UIFont.systemFont(ofSize: 14)
        voltageLabel.textColor = UIColor(named: "Pink")
        voltageLabel.text = NSLocalizedString("Voltage", comment: "Voltage")

        currentLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(voltageLabel.snp.right).offset(45)
        }
        
        currentLabel.font = UIFont.systemFont(ofSize: 14)
        currentLabel.textColor = UIColor(named: "Blue")
        currentLabel.text = NSLocalizedString("Current", comment: "Current")

        powerLable.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(currentLabel.snp.right).offset(45)
        }
        
        powerLable.font = UIFont.systemFont(ofSize: 14)
        powerLable.textColor = UIColor(named: "Purple-2")
        powerLable.text = NSLocalizedString("Power", comment: "Power")
        
        timeLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = UIColor(named: "tintColor")
        timeLabel.text = "00:00:00"
        
        
        let voltageLineView = UIView()
        curveInfoView.addSubview(voltageLineView)
        voltageLineView.snp.makeConstraints { make in
            make.left.equalTo(voltageLabel.snp.right).offset(5)
            make.centerY.equalTo(voltageLabel.snp.centerY)
            make.height.equalTo(1)
            make.width.equalTo(10)
        }
        voltageLineView.backgroundColor = UIColor(named: "Pink")

        let currentLineView = UIView()
        curveInfoView.addSubview(currentLineView)
        currentLineView.snp.makeConstraints { make in
            make.left.equalTo(currentLabel.snp.right).offset(5)
            make.centerY.equalTo(voltageLabel.snp.centerY)
            make.height.equalTo(1)
            make.width.equalTo(10)
        }
        currentLineView.backgroundColor = UIColor(named: "Blue")

        let powerLineView = UIView()
        curveInfoView.addSubview(powerLineView)
        powerLineView.snp.makeConstraints { make in
            make.left.equalTo(powerLable.snp.right).offset(5)
            make.centerY.equalTo(voltageLabel.snp.centerY)
            make.height.equalTo(1)
            make.width.equalTo(10)
        }
        powerLineView.backgroundColor = UIColor(named: "Purple-2")
        
        
        let view1 = UIView()
        curveInfoView.addSubview(view1)
        view1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(timeLabel.snp.top).offset(-3)
        }
        view1.clipsToBounds = true

        view1.addSubview(chartView)
        chartView.snp.makeConstraints { make in

            make.size.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        chartModel.chartType(.spline)           //图标类型
            .animationDuration(0)
            .markerSymbolStyle(.innerBlank)
            .backgroundColor("#f2f2f2")
            .xAxisLabelsEnabled(false)
            .xAxisVisible(false)
            .yAxisVisible(false)
            .tooltipEnabled(false)       //是否弹出所点击点的数据，系统自带的十字架校准线无法去除
            .markerRadius(0)
            .touchEventEnabled(true)      //点击事件
//            .yAxisTickPositions([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150])
            .yAxisMax(150)
            .colorsTheme(["#ff2a7f99","#5599ff99","#9933FF99"])//主题颜色数组
            .legendEnabled(false)//是否启用图表的图例(图表底部的可点击的小圆点)

            .series([
                AASeriesElement()
                    .name(NSLocalizedString("Voltage", comment: "Voltage"))
                    .lineWidth(2.5)
                    .data([0])
                    .step(true)
                ,
                AASeriesElement()
                    .name(NSLocalizedString("Current", comment: "Current"))
                    .lineWidth(2.5)
                    .data([0])
                    .step(true)
                ,
                AASeriesElement()
                    .name(NSLocalizedString("Power", comment: "Power"))
                    .lineWidth(2.5)
                    .data([0])
                    .step(true)
            ])

        chartView.aa_drawChartWithChartModel(chartModel)
//        chartView.isUserInteractionEnabled = false

    
        let lineView1 = UIView()
        view1.addSubview(lineView1)
        lineView1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        lineView1.backgroundColor  = UIColor(named: "Gray-1")
        lineView1.clipsToBounds = true

        let lineView2 = UIView()
        view1.addSubview(lineView2)
        lineView2.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        lineView2.backgroundColor  = UIColor(named: "Gray-1")
        lineView2.clipsToBounds = true

        
        let view2 = UIView()
        view1.addSubview(view2)
        view2.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(100)

        }
            
        view1.addSubview(curveTimeLabel)
        view1.addSubview(voltageCurrentPowerLabel)
        curveTimeLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(-2)
        }
        curveTimeLabel.font = UIFont.systemFont(ofSize: 10)
        curveTimeLabel.textColor = UIColor(named: "tintColor")
        curveTimeLabel.text = "00:00:00"

        voltageCurrentPowerLabel.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(curveTimeLabel.snp.bottom)
        }

        voltageCurrentPowerLabel.font = UIFont.systemFont(ofSize: 10)
        voltageCurrentPowerLabel.textColor = UIColor(named: "tintColor")
        voltageCurrentPowerLabel.text = " "
        
        
        view1.addSubview(curvelineView)
        curvelineView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(1)
        }
//        curvelineView.backgroundColor = UIColor(named: "Gray-2")
        curvelineView.backgroundColor = .orange
        
    }
        
    // MARK: 删除点击线内容
    func removelineView() {
        curveTimeLabel.text = ""
        voltageCurrentPowerLabel.text = ""
        curvelineView.transform = CGAffineTransform(translationX: -10, y: 0)
    }
    
    
    

}
