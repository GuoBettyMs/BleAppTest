//
//  RedpacketRainView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/21.
// ******************************* 红包雨粒子  ***************************************//
//

import UIKit

class RedpacketRainView: UIView {

    let redpacketView = UIView()
    
    //重写父类构造方法
    override init(frame: CGRect){
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI(){
        
        addSubview(redpacketView)
        
        let rainemitter = CAEmitterLayer()
        rainemitter.emitterPosition = CGPoint(x:UIScreen.main.bounds.width/2, y: -10)
        rainemitter.emitterSize =  UIScreen.main.bounds.size
        rainemitter.emitterMode = .surface
        rainemitter.emitterShape = .line

        let raincell = CAEmitterCell()
        raincell.contents = UIImage(named: "redpacket")?.cgImage
        raincell.birthRate = 5
        raincell.lifetime = 20
        raincell.velocity = 8
        raincell.yAcceleration = 200
        raincell.scale = 0.2

        rainemitter.emitterCells = [raincell]
        redpacketView.layer.addSublayer(rainemitter)
        
        
    }
    

}
