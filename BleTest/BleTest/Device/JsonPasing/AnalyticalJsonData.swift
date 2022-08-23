//
//  AnalyticalJsonData.swift
//  BleTest
//
//  Created by gbt on 2022/8/23.
//
/*
    当Json 数据 与解析代码在同一文件时，如何解析Json数据
 */

import UIKit

//var greeting = "Hello, playground"

// MARK: - 解析数据类型的Json数据

let coursesJSON = """
[
    {
        "id": 1,
        "title": "解析JSON",
        "level": "初级",
        "technology": {
            "lan": "swift"
        },
        "service": ["永久保留","实时更新"]
    },
    {
        "id": 2,
        "title": "解析JSON",
        "level": "中级",
        "technology": {
            "lan": "swift"
        },
        "service": ["永久保留","实时更新"]
    },
    {
        "id": 3,
        "title": "解析JSON",
        "level": "高级",
        "technology": {
            "lan": "swift"
        },
        "service": ["永久保留","实时更新"]
    }
]
"""

let courseArrJOSNData = coursesJSON.data(using: .utf8)!

struct CourseArr: Codable{
//    let id: Int
    let title: String
    let level: Level
    let technology: Technology
    let service: [String]
    
    //枚举需要先定义原始值（可以是字符串，整数型、浮点型）
    enum Level: String, Codable{
        case 初级, 中级, 高级
    }
    struct Technology: Codable{
        let lan: String
    }
}

//解析函数
func loadCourseArrData(){
    
    do{
        let courses = try JSONDecoder().decode([CourseArr].self, from: courseArrJOSNData)
        print(courses.count)

    }catch{
        print(error)
    }
}


// MARK: - 解析普通的Json数据

let courseJSON = """
{
    "id": 1,
    "title": "解析JSON",
    "level": "初级",
    "technology": {
        "lan": "swift"
    },
    "service": ["永久保留","实时更新"]
}
"""


let courseJOSNData = courseJSON.data(using: .utf8)!


//原则上属性名称和json数据里的key一样（大小写），属性类型也和value类型一样，不然会解码失败
//注1：不一定要列出json数据里的每一个数据
//注2:json数据中1.key可能有可能没有 2.key有但value可能是nil，需要定义为可选型
struct CourseNormal: Codable{
//    let id: Int
    let title: String
    let level: Level
    let technology: Technology
    let service: [String]
    
    //枚举需要先定义原始值（可以是字符串，整数型、浮点型）
    enum Level: String, Codable{
        case 初级, 中级, 高级
    }
    struct Technology: Codable{
        let lan: String
    }
}

//Course.Level.初级.rawValue
//解析函数
func loadCourseData(){
    do{
        let course = try JSONDecoder().decode(CourseNormal.self, from: courseJOSNData)
        course.title
    }catch{
        print(error)
    }
}

