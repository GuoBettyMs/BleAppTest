//
//  FireWorkView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/21.
//

import UIKit

class FireWorkView: UIView {

    let fireworkbottomView = UIView()
    
    //重写父类构造方法
    override init(frame: CGRect){
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI(){
        
        addSubview(fireworkbottomView)
            
        let rocketlifetime = 1
        
        let firemitter = CAEmitterLayer()
        firemitter.emitterPosition = CGPoint(x:200, y: 400)
        firemitter.emitterSize =  CGSize.init(width: 0, height: 0)
        firemitter.renderMode = .additive
        firemitter.emitterShape = .line
        firemitter.emitterMode = .outline
  
        let rocketcell = CAEmitterCell()
        rocketcell.birthRate = 1
        rocketcell.lifetime = Float(rocketlifetime) + 0.02
        rocketcell.color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1).cgColor
        rocketcell.redRange = 0.7
        rocketcell.greenRange = 0.7
        rocketcell.contents = UIImage(named: "star")?.cgImage
        rocketcell.velocity = 250
        rocketcell.velocityRange = 50
        rocketcell.yAcceleration = 45
        rocketcell.emissionRange = CGFloat(Double.pi)*4
        rocketcell.scale = 0.1


        let sparkcell = CAEmitterCell()
        sparkcell.birthRate = 5000
        sparkcell.lifetime = 2
        sparkcell.contents = UIImage(named: "star")?.cgImage
        sparkcell.velocity = 125
        sparkcell.emissionRange = CGFloat(Double.pi)*2
        sparkcell.scale = 0.05
        sparkcell.scaleSpeed = -0.1
        sparkcell.yAcceleration = 45
        sparkcell.redRange = 0.4
        sparkcell.greenRange = 0.7
        sparkcell.blueRange = 0.9
        sparkcell.alphaSpeed = -0.15
        sparkcell.spin = CGFloat(Double.pi)*2
        sparkcell.spinRange = CGFloat(Double.pi)
        
        sparkcell.beginTime = CFTimeInterval(rocketlifetime)
        
        firemitter.emitterCells = [rocketcell]
        rocketcell.emitterCells = [sparkcell]
        fireworkbottomView.layer.addSublayer(firemitter)

        
        }

}
