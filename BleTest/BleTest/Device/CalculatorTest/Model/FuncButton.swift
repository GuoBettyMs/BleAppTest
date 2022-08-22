//
//  FuncButton.swift
//  IOSApp
//
//  Created by isdt on 2022/3/16.
//

import UIKit

class FuncButton: UIButton {

    init(){
        super.init(frame: CGRect.zero)
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1).cgColor
        self.setTitleColor(UIColor.orange, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        self.setTitleColor(UIColor.black, for: .highlighted)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemeted")
    }

}
