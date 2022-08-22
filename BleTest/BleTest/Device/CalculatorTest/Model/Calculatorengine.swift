//
//  Calculatorengine.swift
//  IOSApp
//
//  Created by isdt on 2022/3/24.
//

import UIKit

class Calculatorengine {

    var isneedfresh = false     //输入时是否将已有的内容清除
    let funcArray: CharacterSet = ["+","-","*","/","^","%"]
    
    func calculatorequation(equation: String) -> Double {
        let elementArray = equation.components(separatedBy: funcArray)
        var tip = 0
        var result: Double = Double(elementArray[0])!
        for char in equation{
            switch char {
            case "+":
                tip += 1
                if elementArray.count > tip {
                    result += Double(elementArray[tip])!
                }

            case "-":
                tip += 1
                if elementArray.count > tip {
                    result -= Double(elementArray[tip])!
                }
            case "*":
                tip += 1
                if elementArray.count > tip {
                    result *= Double(elementArray[tip])!
                }
            case "/":
                tip += 1
                if elementArray.count > tip {
                    result /= Double(elementArray[tip])!
                }
            case "%":
                tip += 1
                if elementArray.count > tip {
                    result = Double(Int(result) % Int(elementArray[tip])!)
                }
            case "^":
                tip += 1
                if elementArray.count > tip {
                    let tmp = result
                    for _ in 1..<Int(elementArray[tip])!{
                        result *= tmp
                    }
                }
            default:
                break
            }
        }
        
        return result
    }
    
}
