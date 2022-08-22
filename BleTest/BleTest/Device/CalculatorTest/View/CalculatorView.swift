//
//  CalculatorView.swift
//  IOSApp
//
//  Created by gbt on 2022/4/20.
//

import UIKit
import SnapKit

class CalculatorView: UIView {
    
    
    @IBOutlet weak var InfoView: UIView!
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let boardView = BoardView()
    let screenView = ScreenView()
    
    override func awakeFromNib() {
        setup()
    }
    
    func setup(){
        InfoView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        //取消scrollView默认的safearea适配
        scrollView.contentInsetAdjustmentBehavior = .never
        
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height*0.9)
        }
        
        contentView.addSubview(boardView)
        contentView.addSubview(screenView)
        
        boardView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalToSuperview().multipliedBy(0.4)
        }

        screenView.snp.makeConstraints { make in
            make.left.right.top.equalTo(0)
            make.bottom.equalTo(boardView.snp.top)
        }

    }
    

    
}
