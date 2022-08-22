//
//  MathUtil.swift
//  IOSApp
//
//  Created by gbt on 2022/5/12.
//

import Foundation

class MathUtil {
    
    static func formatDouble(double: Double, accuracy: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = accuracy
        formatter.maximumFractionDigits = accuracy
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: NSNumber(value: double))!.replacingOccurrences(of: ",", with: ".")
    }
    
    static func filterInt(value: String) -> Int {
        var ret = 0
        var digitSet = CharacterSet()
        digitSet.formUnion(CharacterSet.decimalDigits)
        let valueString = String(value.unicodeScalars.filter{digitSet.contains($0)})
        ret = Int(valueString) ?? 0
        
        return ret
    }

    static func filterDouble(value: String) -> Double {
        var ret:Double = 0
        var digitSet = CharacterSet()
        digitSet.formUnion(CharacterSet.decimalDigits)
        digitSet.insert(charactersIn: ".")
        let valueString = String(value.unicodeScalars.filter{digitSet.contains($0)})
        ret = Double(valueString) ?? 0
        
        return ret
    }
    
    static func getLittleEndianU32(data: Data) -> UInt32 {
        let bytes = [UInt8](data)
        var ret:UInt32 = 0
        ret |= ((UInt32)(bytes[0] & 0xFF) << 24)
        ret |= ((UInt32)(bytes[1] & 0xFF) << 16)
        ret |= ((UInt32)(bytes[2] & 0xFF) << 8)
        ret |= ((UInt32)(bytes[3] & 0xFF) << 0)
        
        return ret
    }
    
    static func getBigEndianU32s(data: Data) -> UInt32 {
        let bytes = [UInt8](data)
        var ret:UInt32 = 0
        ret |= ((UInt32)(bytes[0] & 0xFF) << 0)
        ret |= ((UInt32)(bytes[1] & 0xFF) << 8)
        ret |= ((UInt32)(bytes[2] & 0xFF) << 16)
        ret |= ((UInt32)(bytes[3] & 0xFF) << 24)
        
        return ret
    }

    
}
