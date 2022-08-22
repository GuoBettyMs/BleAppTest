//
//  recordModel.swift
//  IOSApp
//
//  Created by gbt on 2022/7/13.
//

import Foundation

class RecordModel: NSObject{
    var time: String?
    var title: String?
    var body: String?            //内容
    var group: String?            //所在分组
    var noteId: Int?             //主键
    
    func toDictionary() -> Dictionary<String, Any>{
        var dic: [String: Any] = ["time": time!, "title": title!, "body": body!, "ownGroup": group!]
        if let id = noteId{
            dic["noteId"] = id
        }
        return dic
    }
    
    
}
