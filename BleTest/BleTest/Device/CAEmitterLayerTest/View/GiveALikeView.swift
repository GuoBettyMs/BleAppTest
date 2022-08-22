//
//  givealikeView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/20.
// ******************************* 点赞动画粒子  ***************************************//
//

import UIKit
import SnapKit

class GiveALikeView: UIView {

    let givealikeButton = UIButton()
    let likemitter = CAEmitterLayer()
    let likecell = CAEmitterCell()
    
    //重写父类构造方法
    override init(frame: CGRect){
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI(){
            
        addSubview(givealikeButton)
        givealikeButton.snp.remakeConstraints{ make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        givealikeButton.setImage(UIImage(named:"Start"), for: .normal)
    
        
    }
    

}
