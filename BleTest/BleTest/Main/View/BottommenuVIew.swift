//
//  BottommenuVIew.swift
//  IOSApp
//
//  Created by gbt on 2022/4/27.
//

import UIKit

class BottommenuVIew: UIView {

    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var removeL: UILabel!
    @IBOutlet weak var movetopView: UIView!
    @IBOutlet weak var movetopL: UILabel!
    @IBOutlet weak var changenameV: UIView!
    @IBOutlet weak var changenameL: UILabel!
    @IBOutlet weak var upgradeView: UIView!
    @IBOutlet weak var upgradeL: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 加载xib，loadNibNamed("xib的名称")
        contentView = (Bundle.main.loadNibNamed("BottommenuView", owner: self, options: nil)?.last as! UIView)
        // 设置frame
        contentView.frame = frame
        //contentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(contentView)
        contentView.center.y = frame.size.height/2 + 102

        stackView.frame.size.width = contentView.frame.size.width
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissView)))
        
//        removeView.frame.size.width = stackView.frame.size.width/4
//        movetopView.frame.size.width = stackView.frame.size.width/4
//        changenameV.frame.size.width = stackView.frame.size.width/4
//        upgradeView.frame.size.width = stackView.frame.size.width/4

        
        stackView.layer.shadowOpacity = 0.5        //图层的不透明度
        stackView.layer.shadowColor = UIColor.gray.cgColor
        stackView.layer.shadowRadius = 3
        stackView.layer.shadowOffset = CGSize(width: 1,height: 1)          //图层阴影的偏移量
        stackView.layer.cornerRadius = 20
        
        
        movetopL.text = NSLocalizedString("MoveTop", comment: "MoveTop")
        removeL.text = NSLocalizedString("Remove", comment: "Remove")
        upgradeL.text = NSLocalizedString("Upgrade", comment: "Upgrade")
        changenameL.text = NSLocalizedString("Rename", comment: "Rename")
        
        UIView.animate(withDuration: 0.15, animations: {
            self.contentView.center.y = frame.size.height/2-10
                }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismissView(){
        dismiss()
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.contentView.center.y = self.contentView.frame.height-102
            self.alpha = 0
        }) { (true) in
            self.removeFromSuperview()
            self.contentView?.removeFromSuperview()
        }
    }
    
    

    
}
