//
//  Logger.swift
//  IOSApp
//
//  Created by isdt on 2022/3/8.
//

import Foundation

class Logger {
    public static func debug(_ s:String, _ file: String = #file, _ line: Int = #line) {
        let file = (file as NSString).lastPathComponent
        #if DEBUG
        NSLog(file + "[\(line)]:" + s)
        #endif
    }
}
