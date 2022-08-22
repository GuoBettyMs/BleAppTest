//
//  UpdateAlertView.swift
//  IOSApp
//
//  Created by gbt on 2022/5/12.
//

import UIKit
import SnapKit

class UpdateAlertView: UIView {

    var contentView = UIView()
    var tipsV = UIView()
    var updateCircleArcView = CirecleView()
    var percentageL = UILabel()
    var titleL = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadViewFromNib()
    }

    func loadViewFromNib() {
        
        contentView.backgroundColor = .blue
        contentView.snp.makeConstraints{ make in
            make.height.equalTo(400)
            make.width.equalTo(400)
            make.top.equalTo(50)
        }
        addSubview(contentView)
        

        tipsV.backgroundColor = .red
        tipsV.snp.makeConstraints{ make in
            make.height.equalTo(100)
            make.width.equalTo(100)
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
        }
        contentView.addSubview(tipsV)
        
        let progressViewFrame = CGRect(x: 100, y: 200, width:150, height: 150)
        updateCircleArcView  = CirecleView(frame: progressViewFrame)
        updateCircleArcView.setStrokeWidth(innerWidth: 0, secondWidth: 0, outerWidth: 0, progressWidth: 33.0)
        updateCircleArcView.setStrokeColor(innerColor: .clear, secondColor: .clear, outerColor: .clear, progressColor: UIColor.blue, progressBGColor: .gray)

        updateCircleArcView.setProgress(50)
        updateCircleArcView.animateCircle(duration: 0.25)
        updateCircleArcView.setStrokeAnimation(duration: 2)
        updateCircleArcView.backgroundColor = .gray
        tipsV.addSubview(updateCircleArcView)


        
        
        percentageL.text = "100%"
        percentageL.textColor = .white
        percentageL.snp.makeConstraints{ make in
            make.height.equalTo(30)
            make.width.equalTo(50)
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
        }
        tipsV.addSubview(percentageL)

        titleL.text = "更新固件"
        titleL.textColor = .white
        titleL.snp.makeConstraints{ make in
            make.height.equalTo(30)
            make.width.equalTo(50)
            make.top.equalTo(50)
            make.centerX.equalTo(tipsV.snp.centerX)
        }
        contentView.addSubview(titleL)
        

        
    }
    

}
