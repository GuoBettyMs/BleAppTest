//
//  ScreenView.swift
//  IOSApp
//
//  Created by isdt on 2022/3/16.
//

import UIKit

class ScreenView: UIView {

    var inputLabel: UILabel?
    var historyLabel: UILabel?
    var inputstring = ""
    var historystring = ""
    let figureArray: Array<Character> = ["0","1","2","3","4","5","6","7","8","9"]
    var funcArray = ["+","-","*","/","%","^"]
    
    init() {
        inputLabel = UILabel()
        historyLabel = UILabel()
        super.init(frame: CGRect.zero)
        installUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func installUI() {
        inputLabel?.textAlignment = .right
        historyLabel?.textAlignment = .right
        inputLabel?.font = UIFont.systemFont(ofSize: 34)
        historyLabel?.font = UIFont.systemFont(ofSize: 25)
        inputLabel?.textColor = UIColor.orange
        historyLabel?.textColor = UIColor.black
        //文字大小可根据字数自动调整
        inputLabel?.adjustsFontSizeToFitWidth = true
        historyLabel?.adjustsFontSizeToFitWidth = true
        //允许文字缩小的最小比例为0.5
        inputLabel?.minimumScaleFactor = 0.5
        historyLabel?.minimumScaleFactor = 0.5
        //byTruncatingHead 以单词为单位换行，若是单行，开始部分为省略号，若是多行，结尾部分为省略号加4个字符
        inputLabel?.lineBreakMode = .byTruncatingHead
        historyLabel?.lineBreakMode = .byTruncatingHead
        inputLabel?.numberOfLines = 0
        historyLabel?.numberOfLines = 0
        
        self.addSubview(inputLabel!)
        self.addSubview(historyLabel!)
        
        historyLabel?.backgroundColor = UIColor.gray
        inputLabel?.backgroundColor = UIColor.brown
        inputLabel?.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
            make.height.equalToSuperview().multipliedBy(0.2).offset(-10)
        }
        historyLabel?.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(inputLabel!.snp.top).offset(10)
            make.height.equalToSuperview().multipliedBy(0.2).offset(-10)
            
        }
        
    }
    //创建输入信息的接口,设定输入规定：每次输入开头不能是运算符，不能同时输入两个运算符
    func inputcontent(content: String){
        //contains(Element)返回bool值，判断序列是否包含给定元素
        //如果content 不是数字，也不是运算符，则返回不处理
        if !figureArray.contains(content.last!) && !funcArray.contains(content){
            return;
        }
     
        if inputstring.count > 0{
          
            if figureArray.contains(inputstring.last!){         //最后一个字符是数字，可添加0-9，运算符和小数点
                inputstring.append(content)
                inputLabel?.text = inputstring
       
            }else{                                              //最后一个字符不是数字，后面只能添加数字0-9
                
                if figureArray.contains(content.last!){        //如果新增加的字符符合数字0-9，则添加
                    inputstring.append(content)
                    inputLabel?.text = inputstring
                }
                
            }
 
        }else {         //如果是首次输入字符,只能输入数字
            if figureArray.contains(content.last!){
                inputstring.append(content)
                inputLabel?.text = inputstring
            }
        }
 
    }
    
    func refreshhistory(){
        historystring = inputstring
        historyLabel?.text = historystring
    }
    
    func clearcontent(){
        inputstring = ""
    }
    
    func deletelastinput(){
        if inputstring.count > 0{
            inputstring.remove(at: inputstring.index(before: inputstring.endIndex))
            inputLabel?.text = inputstring
        }
    }
}
