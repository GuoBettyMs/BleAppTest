//
//  StringSubscript.swift
//  BattAir
//
//  Created by isdt on 2021/5/20.
//  Copyright © 2021 ISDT. All rights reserved.
//

import Foundation
import UIKit
// MARK: - 字符串截取
extension String {
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
}

extension Date {
    var milliTime: Int {
        let time = self.timeIntervalSince1970
        return Int(CLongLong(round(time*1000)))
    }
    
    var secondTime: Int {
        let time = self.timeIntervalSince1970
        return Int(time)
    }
}

extension CharacterSet {
    func getValue(value: String, characters: String) -> String {
        var digitSet = CharacterSet()
        digitSet.formUnion(CharacterSet.decimalDigits)
        digitSet.insert(charactersIn: characters)
        return String(value.unicodeScalars.filter{digitSet.contains($0)})
    }
}


extension UIView {
    func addCorner(conrners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}


extension RangeReplaceableCollection where Indices: Equatable {
    mutating func rearrange(from: Index, to: Index) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indices")
        insert(remove(at: from), at: to)
    }
}


extension Double {
    
    func decimal(_ base: Int) -> Double {
        
//        let temp = "\(self)"
        let temp = String(format: "%.\(base)f", self)
        let temp1 = "\(Int(self))"
        let count = temp1.count + base + 1
        if  count <= temp.count {
            return Double(temp[0, count])!
        }else {
            return Double(temp[0, temp.count])!
        }
    }
}



@objc enum BorderType:NSInteger {
    
    case top,left,bottom,right
    
}

extension UIView {
    
    // MARK: - 为视图加上边框 ，枚举数组可以填充上下左右四个边
   @objc func addBorder(color: UIColor?, size: CGFloat, borderTypes:NSArray){
    
    var currentColor:UIColor?
    
    if let _ = color{
        currentColor = color
    }else{
        currentColor = UIColor.black
    }
    
        for borderType in borderTypes{
            let bt: NSNumber = borderType as! NSNumber
            self.addBorderLayer(color: currentColor!, size: size, boderType: BorderType(rawValue: bt.intValue)!)
        }
    
    }
    
   @objc func addBorderLayer(color: UIColor, size: CGFloat, boderType: BorderType){
        
        let layer:CALayer = CALayer()
       layer.backgroundColor = color.cgColor
        self.layer.addSublayer(layer)
        
        switch boderType{
            
        case .top:
            layer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: size)
            
        case .left:
            layer.frame = CGRect(x: 0, y: 0, width: size, height: self.frame.height)
            
        case .bottom:
            layer.frame = CGRect(x: 0, y: self.frame.height - size, width: self.frame.width, height: size)
            
        case .right:
            layer.frame = CGRect(x: self.frame.width - size, y: 0, width: size, height: self.frame.height)
            
//        default:
//            return;
        
        }
    }
}
