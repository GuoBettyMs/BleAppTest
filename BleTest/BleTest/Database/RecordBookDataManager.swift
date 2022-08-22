//
//  RecordBookDataManager.swift
//  IOSApp
//
//  Created by gbt on 2022/7/13.
//

import UIKit
import SQLite

//所有方法都封装成类方法，所以使用时无须创建RecordBookDataManager 实例
class RecordBookDataManager: NSObject {
    
    static var sqlHandle: Connection?       //创建一个数据库操作对象属性
    static var isOpen = false               //标记是否已打开数据库
    

    // MARK: 存储分组数据
    class func saveGroup(name: String){
        if !isOpen{
            self.openDataBase()
        }
        let groupTable = Table("group")
        let groupName = Expression<String?>("groupName")
        let insert = groupTable.insert(groupName <- name)
        let _ = try! sqlHandle?.run(insert)
    }
    
    // MARK: 获取所有的分组数据
    class func getGroupData() -> [String]{
        if !isOpen{
            self.openDataBase()
        }
        var array: [String] = []
        let groupTable = Table("group")
        //进行查询数据操作
        for group in try! sqlHandle!.prepare(groupTable){
            //遍历查询到的数据，赋值到结果数组array
            let name = Expression<String?>("groupName")
            if let n = try? group.get(name) {
                array.append(n)
            }
        }
        return array
    }

    
    // MARK: 添加新的记事
    class func addNote(note: RecordModel){
        if !isOpen{
            self.openDataBase()
        }
        let noteTable = Table("noteTable")
        let ownGroup = Expression<String?>("ownGroup")
        let body = Expression<String?>("body")
        let title = Expression<String?>("title")
        let time = Expression<String?>("time")
        let insert = noteTable.insert(ownGroup <- note.group, body <- note.body, title <- note.title, time <- note.time)
        let _ = try! sqlHandle?.run(insert)
    }
    
    // MARK: 根据记事获取记事的方法
    class func getNote(group: String) -> [RecordModel]{
        if !isOpen{
            self.openDataBase()
        }

        //进行查询数据操作
        let noteTable = Table("noteTable")
        var array = Array<RecordModel>()
        let ownGroup = Expression<String?>("ownGroup")
        for note in try! sqlHandle!.prepare(noteTable.filter(ownGroup.like(group))){
            //遍历查询到的数据，赋值到结果数组array
            let ownGroup = Expression<String?>("ownGroup")
            let body = Expression<String?>("body")
            let nId = Expression<Int64>("id")
            let title = Expression<String?>("title")
            let time = Expression<String?>("time")
            let model = RecordModel()
            if let n = try? note.get(nId) {
                model.noteId = Int(n)
            }
            if let n = try? note.get(ownGroup) {
                model.group = n
            }
            if let n = try? note.get(body) {
                model.body = n
            }
            if let n = try? note.get(title) {
                model.title = n
            }
            if let n = try? note.get(time) {
                model.time = n
            }
            array.append(model)
        }
        return array
    }
    
    // MARK: 更新一条记事内容
    class func updateNote(note: RecordModel){
        if !isOpen{
            self.openDataBase()
        }
        let noteTable = Table("noteTable")
        let nId = Expression<Int64>("id")
        let alice = noteTable.filter(nId == Int64(note.noteId!))                //根据主键ID 进行更新
        let ownGroup = Expression<String?>("ownGroup")
        let body = Expression<String?>("body")
        let title = Expression<String?>("title")
        let time = Expression<String?>("time")
        let _ = try? sqlHandle?.run(alice.update(ownGroup <- note.group, body <- note.body, title <- note.title, time <- note.time))
    }
    
    // MARK: 删除一条记事
    class func deleteNote(note: RecordModel){
        if !isOpen{
            self.openDataBase()
        }
        let noteTable = Table("noteTable")
        let nId = Expression<Int64>("id")
        let alice = noteTable.filter(nId == Int64(note.noteId!))                //根据主键ID 进行删除
        let _ = try? sqlHandle?.run(alice.delete())
    }
    
    // MARK: 删除一个分组,包括分组下的所有记事
    class func deleteGroup(name: String){
        if !isOpen{
            self.openDataBase()
        }
        let noteTable = Table("noteTable")
        let ownGroup = Expression<String?>("ownGroup")
        let alice = noteTable.filter(ownGroup == name)                //删除分组下的所有记事
        let _ = try? sqlHandle?.run(alice.delete())
        
        let groupTable = Table("group")
        let gName = Expression<String?>("groupName")
        let gAlice = groupTable.filter(gName == name)                //删除分组
        let _ = try? sqlHandle?.run(gAlice.delete())
    }
    
    
    // MARK: 打开数据库
    class func openDataBase(){
        //获取沙盒路径
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        //进行文件名的拼接
        let file = path + "/DataBase.sqlite"
        //打开数据库，如果数据库不存在就进行创建
        sqlHandle = try? Connection(file)
        
        let groupTable = Table("group")                     //创建存储表
        let name = Expression<String?>("groupName")         //设置表字段
        let id = Expression<Int64>("id")                    //设置表字段
        
        //执行建表
        let _ = try? sqlHandle?.run(groupTable.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
        
        //创建记事存储表
        let noteTable = Table("noteTable")
        let nId = Expression<Int64>("id")
        let ownGroup = Expression<String?>("ownGroup")
        let body = Expression<String?>("body")
        let title = Expression<String?>("title")
        let time = Expression<String?>("time")
        
        //执行建表
        let _ = try? sqlHandle?.run(noteTable.create(block: { (t) in
            t.column(nId, primaryKey: true)
            t.column(ownGroup)
            t.column(body)
            t.column(title)
            t.column(time)
        }))
        
        
        isOpen = true         //设置数据库打开标志
    }
}
