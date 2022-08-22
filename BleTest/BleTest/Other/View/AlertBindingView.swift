//
//  AlertBindingView.swift
//  IOSApp
//
//  Created by gbt on 2022/5/10.
//

import UIKit
import SnapKit

class AlertBinding: UIView {
    
    let imgView = UIImageView()
    let titleLabel = UILabel()
    let confirmButton = UIButton.init(type: .custom)
    let timeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        let infoView = UIView()
        imgView.image = UIImage(named: "Air8Icon")
        infoView.backgroundColor = UIColor(named: "UpgradeBG")
        
        addSubview(infoView)
        infoView.snp.remakeConstraints { make in
            make.width.equalTo(320)
            make.height.equalTo(280)
            make.center.equalToSuperview()
        }
        
        infoView.layer.cornerRadius = 20
        
        infoView.addSubview(imgView)
        imgView.snp.remakeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalTo(infoView)
        }
        
        confirmButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for:.normal)
        confirmButton.setTitleColor(UIColor(named: "Main_TextColor"), for: .normal)
//        confirmButton.backgroundColor = UIColor(named: "BarColor")
        
        infoView.addSubview(confirmButton)
        confirmButton.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
        }

        let img = UIImageView()
        img.backgroundColor = UIColor.init(named: "Main_Line-Color")
        infoView.addSubview(img)
        img.snp.remakeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(0)
            make.height.equalTo(0.5)
            make.width.equalToSuperview()
        }
        
        infoView.addSubview(timeLabel)
        timeLabel.text = "30S"
        timeLabel.textColor = UIColor(named: "Main_TextColor")
        timeLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(img.snp.top).offset(-20)
            make.centerX.equalTo(infoView)
        }
        
        infoView.addSubview(titleLabel)
        titleLabel.text = NSLocalizedString("AddHint", comment: "AddHint")
        titleLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(timeLabel.snp.top).offset(-30)
            make.centerX.equalTo(infoView)
        }
        titleLabel.textColor = UIColor(named: "Main_TextColor")
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.numberOfLines = 0
        
    }
    
}

