//
//  BoardView.swift
//  IOSApp
//
//  Created by isdt on 2022/3/16.
//

import UIKit
import SnapKit

class BoardView: UIView {
    
    var dataArray = ["0","^",".","=",
                     "1","2","3","+",
                     "4","5","6","-",
                     "7","8","9","*",
                     "AC","Del","%","/"]
    
    var buttonArray:[UIButton] = []
    
    
    //重写父类构造方法
    override init(frame: CGRect){
        super.init(frame: frame)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI() {
        var frontButton: FuncButton!
        for index in 0..<20 {
            let funcButton = FuncButton()
            //先添加控件，再进行自动布局
            self.addSubview(funcButton)
            funcButton.snp.makeConstraints { make in
                
                if index%4 == 0 {   //按钮为每一行第一个时
                    make.left.equalTo(0)
                }else {
                    make.left.equalTo(frontButton.snp.right)
                }
              
                if index/4 == 0 {     //按钮为第一行时，靠父视图的底部对齐
                    make.bottom.equalTo(0)
                }else if index%4 == 0 {     //按钮不在第一行时但为每行第一个时
                    make.bottom.equalTo(frontButton.snp.top)
                }else {
                    make.bottom.equalTo(frontButton.snp.bottom)
                }
                
                make.width.equalToSuperview().multipliedBy(0.25)    //约束宽度为父视图宽度的0.25倍
                make.height.equalToSuperview().multipliedBy(0.2)
                
            }
            
            funcButton.tag = index + 100
            funcButton.setTitle(dataArray[index], for: .normal)
            
            //对上一个按钮进行更新保存
            frontButton = funcButton
            buttonArray.append(funcButton)
        }
        
        
    }

}

