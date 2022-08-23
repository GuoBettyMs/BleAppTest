//
//  Course.swift
//  IOSApp
//
//  Created by gbt on 2022/5/5.
//

import Foundation

struct Course: Codable{

    let title: String
    let services: [String]
    let lessonCount: Int
    
    struct Technology: Codable{
        let lan: String
        let editor: String
        let framework: String
    }

}

