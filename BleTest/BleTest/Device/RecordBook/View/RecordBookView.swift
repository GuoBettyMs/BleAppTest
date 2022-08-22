//
//  RecordBookView.swift
//  IOSApp
//
//  Created by gbt on 2022/7/12.
//

import UIKit
import SnapKit

class RecordBookView: UIView {

    let scrollView = UIScrollView()
    let interItemSpacing = 15           //列间距
    let lineSpcing = 25                 //行间距
    var groupTitleArray: [String] = []
    var groupBtnArray: [UIButton] = []

    var homeButtonDelegate: HomeButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }

    func  setup(){

        addSubview(scrollView)
        scrollView.snp.makeConstraints{ make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(800)
        }
        
        
        scrollViewUpdateLayout()

    }

    func scrollViewUpdateLayout(){
        let itemWidth = (self.frame.size.width-CGFloat(4*interItemSpacing))/3
        let itemHeight = itemWidth/3*4
        groupBtnArray.forEach({(element) in
            element.removeFromSuperview()
        })
        groupBtnArray.removeAll()
        if groupTitleArray != nil && groupTitleArray.count>0{
            for index in 0..<groupTitleArray.count{
                let btn = UIButton(type: .system)
                btn.setTitle(groupTitleArray[index], for: .normal)
                btn.frame = CGRect(x: CGFloat(interItemSpacing)+CGFloat(index%3)*(itemWidth+CGFloat(interItemSpacing)),
                                   y: CGFloat(lineSpcing)+CGFloat(index/3)*(itemHeight+CGFloat(lineSpcing)),
                                   width: itemWidth, height: itemHeight)
                btn.backgroundColor = UIColor(red: 1, green: 242/255, blue: 216/255, alpha: 1)
                btn.layer.masksToBounds = true
                btn.layer.cornerRadius = 15
                btn.setTitleColor(.gray, for: .normal)
                btn.tag = index
                btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
                scrollView.addSubview(btn)
                groupBtnArray.append(btn)
            }
            scrollView.contentSize = CGSize(width: 0, height: groupBtnArray.last!.frame.origin.y+groupBtnArray.last!.frame.size.height+CGFloat(lineSpcing))
            
            
//            var frontButton = UIButton(type: .system)
//            for index in 0..<groupTitleArray.count{
//                let funcButton = UIButton(type: .system)
//                //先添加控件，再进行自动布局
//                scrollView.addSubview(funcButton)
//                funcButton.snp.makeConstraints { make in
//
//                    if index%3 == 0 {   //按钮为每一行第一个时
//                        make.left.equalTo(interItemSpacing)
//                    }else {
//                        make.left.equalTo(frontButton.snp.right).offset(interItemSpacing)
//                    }
//
//                    if index/3 == 0 {     //按钮为第一行时，靠父视图的底部对齐
//                        make.top.equalTo(lineSpcing)
//                    }else if index%3 == 0 {     //按钮不在第一行时但为每行第一个时
//                        make.top.equalTo(frontButton.snp.bottom).offset(lineSpcing)
//                    }else {
//                        make.top.equalTo(frontButton.snp.top)
//                    }
//
//                    make.width.equalToSuperview().multipliedBy(0.27)    //约束宽度为父视图宽度的0.25倍
//                    make.height.equalToSuperview().multipliedBy(0.2)
//
//                }
//                funcButton.backgroundColor = UIColor(red: 1, green: 242/255, blue: 216/255, alpha: 1)
//                funcButton.layer.cornerRadius = 15
//                funcButton.tag = index
//                funcButton.setTitle(groupTitleArray[index], for: .normal)
//                funcButton.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
//
//                //对上一个按钮进行更新保存
//                frontButton = funcButton
//                groupBtnArray.append(funcButton)
//            }
//
//            scrollView.contentSize = CGSize(width: 0, height: (CGFloat(lineSpcing)+itemHeight)*CGFloat(groupTitleArray.count/3)+100)
        }
    }
    
    // MARK: 点击事件
    @objc func btnClick(btn: UIButton){
        print(groupTitleArray[btn.tag])
        if homeButtonDelegate != nil{
            //当 groupBtn 被点击时，执行homeButtonClick(title: String) 函数
            homeButtonDelegate?.homeButtonClick(title: groupTitleArray[btn.tag])
        }
    }

}

protocol HomeButtonDelegate{
    func homeButtonClick(title: String)
}
