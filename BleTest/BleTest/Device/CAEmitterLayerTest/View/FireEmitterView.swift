//
//  FireView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/21.
// ******************************* 火焰粒子  ***************************************//
//

import UIKit

class FireEmitterView: UIView {

    let firebottomView = UIView()
    
    //重写父类构造方法
    override init(frame: CGRect){
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI(){
        
        addSubview(firebottomView)
            
        let firemitter = CAEmitterLayer()
        firemitter.emitterPosition = CGPoint(x:100, y: 200)
        firemitter.emitterSize =  CGSize.init(width: 0, height: 0)
        firemitter.renderMode = .additive
  
        let firecell = CAEmitterCell()
        firecell.birthRate = 500
        firecell.lifetime = 3.0
        firecell.lifetimeRange = 1.5
        firecell.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.1).cgColor
        firecell.contents = UIImage(named: "emittercell")?.cgImage
        firecell.velocity = 120
        firecell.velocityRange = 60
        firecell.emissionLongitude = CGFloat(Double.pi + Double.pi/2)
        firecell.emissionRange = CGFloat(Double.pi)
        firecell.scaleSpeed = 0.25
        firecell.spin = 0.2
        firecell.scale = 0.25

//
//        let smokecell = CAEmitterCell()
//        smokecell.birthRate = 1000
//        smokecell.lifetime = 4.0
//        smokecell.lifetimeRange = 1.5
//        smokecell.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05).cgColor
//        smokecell.contents = UIImage(named: "emittercell")?.cgImage
//        smokecell.velocity = 100
//        smokecell.emissionLongitude = CGFloat(Double.pi + Double.pi/2)
        firecell.emissionRange = CGFloat(Double.pi)
        
        firemitter.emitterCells = [firecell]
        firebottomView.layer.addSublayer(firemitter)

        
        }
    

}
