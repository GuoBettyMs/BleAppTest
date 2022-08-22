//
//  EmittertestView.swift
//  IOSApp
//
//  Created by isdt on 2022/4/7.
//

import UIKit
import SnapKit

class EmittertestView: UIView {

    
    @IBOutlet weak var InfoView: UIView!
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let backgroundView = UIView()
    let rainView = UIView()
    let firesparkView = UIView()
    let fireView = UIView()
   
    
    let givealikeView = GiveALikeView()
    let redpacketrainView = RedpacketRainView()
    let fireemitterView = FireEmitterView()
    let fireworkView = FireWorkView()
 
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    
    func setup(){

        InfoView.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1280)
        }
        
        contentView.addSubview(backgroundView)
        contentView.addSubview(rainView)
        contentView.addSubview(fireView)
        contentView.addSubview(firesparkView)
        
        backgroundView.snp.remakeConstraints{ make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
        }
        backgroundView.backgroundColor = .black
        backgroundView.layer.cornerRadius = 20
        
        backgroundView.addSubview(givealikeView)
        givealikeView.snp.remakeConstraints{ make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(50)
        }

        rainView.snp.remakeConstraints{ make in
            make.top.equalTo(backgroundView.snp.bottom).offset(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
        }
        rainView.backgroundColor = .black
        rainView.layer.cornerRadius = 20
        rainView.clipsToBounds = true

        rainView.addSubview(redpacketrainView)
        redpacketrainView.snp.remakeConstraints{ make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        firesparkView.snp.remakeConstraints{ make in
            make.top.equalTo(rainView.snp.bottom).offset(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(400)
        }
        firesparkView.backgroundColor = .black
        firesparkView.layer.cornerRadius = 20
        firesparkView.clipsToBounds = true

        firesparkView.addSubview(fireworkView)
        fireworkView.snp.remakeConstraints{ make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(400)
            make.centerX.equalToSuperview()
        }
        
        fireView.snp.remakeConstraints{ make in
            make.top.equalTo(firesparkView.snp.bottom).offset(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(400)
        }
        fireView.backgroundColor = .black
        fireView.layer.cornerRadius = 20
        fireView.clipsToBounds = true

        fireView.addSubview(fireemitterView)
        fireemitterView.snp.remakeConstraints{ make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
        }
        
        
    }
    
//// ******************************* 点赞动画粒子  ***************************************//
//    let likemitter = CAEmitterLayer()
//    func givealike(){
//
////        givealikeButton.frame = CGRect(x:self.bounds.size.width/2 - 15, y: self.bounds.size.height/2 - 15, width: 30, height: 30)
//        givealikeButton.frame = CGRect(x: UIScreen.main.bounds.width/2-15, y: UIScreen.main.bounds.height/2-15, width: 30, height: 30)
//        givealikeButton.setImage(UIImage(named:"Start"), for: .normal)
//        givealikeButton.addTarget(self, action: #selector(pressbtn), for: .touchUpInside)
//        addSubview(givealikeButton)
//
//    }
//
//    @objc func pressbtn(){
//        givealikeButton.setImage(UIImage(named:"Stop"), for: .normal)
//
//        let likemitter = CAEmitterLayer()
//        likemitter.emitterPosition = CGPoint(x:self.bounds.size.width/2, y: self.bounds.size.height/2)
//        likemitter.emitterSize = CGSize.init(width: 80, height: 0)
//        likemitter.emitterMode = .outline
//        likemitter.emitterShape = .circle
//        likemitter.renderMode = .oldestLast
//
//        let likecell = CAEmitterCell()
//        likecell.name = "explosion"
//        likecell.contents = UIImage(named: "emittercell")?.cgImage
//        likecell.alphaRange = 0.1
//        likecell.alphaSpeed = -0.5
//        likecell.lifetime = 0.2
//        likecell.lifetimeRange = 0.1
//        likecell.birthRate = 300
//        likecell.velocity = 100
//        likecell.velocityRange = 10
//        likecell.scale = 0.03
//
//        likemitter.emitterCells = [likecell]
//        layer.addSublayer(likemitter)
//
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
//            likemitter.setValue(0.0, forKeyPath: "emitterCells.explosion.birthRate")
//        }
//
//    }
    
// ******************************* 红包雨粒子  ***************************************//
//    func redpacketrain(){
//        let rainemitter = CAEmitterLayer()
////        rainemitter.emitterPosition = CGPoint(x:self.bounds.size.width/2, y: -10)
////        rainemitter.emitterSize = self.frame.size
//        rainemitter.emitterPosition = CGPoint(x:UIScreen.main.bounds.width/2, y: -10)
//        rainemitter.emitterSize =  UIScreen.main.bounds.size
//        rainemitter.emitterMode = .surface
//        rainemitter.emitterShape = .line
//
//        let raincell = CAEmitterCell()
//        raincell.contents = UIImage(named: "emittercell")?.cgImage
//        raincell.birthRate = 5
//        raincell.lifetime = 20
//        raincell.velocity = 8
//        raincell.yAcceleration = 500
//        raincell.scale = 1
//
//        rainemitter.emitterCells = [raincell]
//        layer.addSublayer(rainemitter)
//    }
    
// ******************************* 火焰粒子  ***************************************//
//    func fireemitterexample(){
//        let firemitter = CAEmitterLayer()
////        firemitter.emitterPosition = CGPoint(x:self.bounds.size.width / 2, y:self.bounds.size.height-20)
////        firemitter.emitterSize = CGSize(width: self.bounds.width-100, height: 20)
//        firemitter.emitterPosition = CGPoint(x:200, y: 600)
//        firemitter.emitterSize =  CGSize.init(width: 10, height: 5)
//        firemitter.renderMode = .additive
//
//        let firecell = CAEmitterCell()
//        firecell.birthRate = 500
//        firecell.lifetime = 3.0
//        firecell.lifetimeRange = 1.5
//        firecell.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.1).cgColor
//        firecell.contents = UIImage(named: "emittercell")?.cgImage
//        firecell.velocity = 120
//        firecell.velocityRange = 60
//        firecell.emissionLongitude = CGFloat(Double.pi + Double.pi/2)
//        firecell.emissionRange = CGFloat(Double.pi)
//        firecell.scaleSpeed = 0.5
//        firecell.spin = 0.2
//
//        let smokecell = CAEmitterCell()
//        smokecell.birthRate = 1000
//        smokecell.lifetime = 4.0
//        smokecell.lifetimeRange = 1.5
//        smokecell.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05).cgColor
//        smokecell.contents = UIImage(named: "emittercell")?.cgImage
//        smokecell.velocity = 200
//        smokecell.velocity = 100
//        smokecell.emissionLongitude = CGFloat(Double.pi + Double.pi/2)
//        firecell.emissionRange = CGFloat(Double.pi)
//
//        firemitter.emitterCells = [firecell,smokecell]
//        layer.addSublayer(firemitter)
//
//    }
    


}
