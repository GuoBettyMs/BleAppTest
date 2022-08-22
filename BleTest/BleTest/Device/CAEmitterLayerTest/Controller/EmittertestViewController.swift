//
//  EmittertestViewController.swift
//  IOSApp
//
//  Created by isdt on 2022/3/16.
//

import UIKit
import RxSwift
import RxCocoa


class EmittertestViewController: BaseobjectViewController<EmittertestView> {

    var disposeBag = DisposeBag()
    var buttonBool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI(){
        navigationBarColor(backgroundColor: .clear, titleColor: UIColor.init(named: "NaviBGColor")!)
        
        container.givealikeView.givealikeButton.rx.tap
            .subscribe(onNext:{ [weak self] in
                
                guard let selfs = self else{
                    return
                }

                selfs.container.givealikeView.givealikeButton.setImage(UIImage(named:"Stop"), for: .normal)
             
                selfs.container.givealikeView.likecell.birthRate = 300
                selfs.container.givealikeView.layer.addSublayer(selfs.container.givealikeView.likemitter)

                selfs.container.givealikeView.likemitter.emitterPosition = CGPoint(x:20, y:30)
                selfs.container.givealikeView.likemitter.emitterSize = CGSize.init(width: 80, height: 0)
                selfs.container.givealikeView.likemitter.emitterMode = .outline
                selfs.container.givealikeView.likemitter.emitterShape = .circle
                selfs.container.givealikeView.likemitter.renderMode = .oldestFirst

                selfs.container.givealikeView.likecell.name = "explosion"
                selfs.container.givealikeView.likecell.contents = UIImage(named: "emittercell")?.cgImage
                selfs.container.givealikeView.likecell.alphaRange = 0.2
                selfs.container.givealikeView.likecell.alphaSpeed = -0.1
                selfs.container.givealikeView.likecell.lifetime = 0.7
                selfs.container.givealikeView.likecell.lifetimeRange = 0.3
                selfs.container.givealikeView.likecell.birthRate = 300
                selfs.container.givealikeView.likecell.velocity = 40
                selfs.container.givealikeView.likecell.velocityRange = 10
                selfs.container.givealikeView.likecell.scale = 0.03

                selfs.container.givealikeView.likemitter.emitterCells = [selfs.container.givealikeView.likecell]
                selfs.container.givealikeView.layer.addSublayer(selfs.container.givealikeView.likemitter)

                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                    selfs.container.givealikeView.likemitter.setValue(0, forKeyPath: "emitterCells.explosion.birthRate")
                    selfs.container.givealikeView.givealikeButton.setImage(UIImage(named:"Start"), for: .normal)
                }
                
            }).disposed(by:disposeBag)
        
    }

 
    @IBAction func BackAction(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    
    
    
    

}
