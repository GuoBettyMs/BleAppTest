//
//  ScanDbManager.swift
//  IOSApp
//
//  Created by gbt on 2022/4/25.
//

import Foundation
import SQLite
import SQLite3

struct ScanDbManager {
    var db:Connection!
    
    private let testSQLTable = Table("testSQLTable")  //表名
    private let id = Expression<Int>("id")  //主键
    private let type = Expression<String>("type")
    private let titlename = Expression<String>("titlename")
    private let identifier = Expression<String>("identifier")
    private let detail = Expression<String>("detail")
    private let versionNum = Expression<String>("versionNum")
    
    let sqlFilePath = NSHomeDirectory() + "/Documents/testSQL.sqlite3"  // 设置数据库路径
    let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                    ).first!
    
    init() {
        if db == nil {
            do {
                db = try Connection(sqlFilePath)
                db.busyTimeout = 5.0
                let count = try db.scalar("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = 'testSQLTable'")
                let value = try db.scalar("SELECT count(*) FROM sqlite_master WHERE name = 'testSQLTable' AND SQL LIKE '%versionNum%'")
                //            let versionNumcount = value.columnNames
                if Int.fromDatatypeValue(count as! Int64) < 1 {
                    createdsqlite3()
                }else {
                    if Int.fromDatatypeValue(value as! Int64) == 0 {
                        Logger.debug("数据为空")
                        try db.run("ALTER TABLE 'testSQLTable' ADD COLUMN 'versionNum' 'String'")    //数据库的表testSQLTable 增加一列 versionNum
//                        try db.run("UPDATE 'scanTable' SET 'versionNum' = '0'")
                        for data in try! db.prepare(testSQLTable).reversed() {
                            let data = testSQLTable.filter(identifier == data[identifier])        //根据identifier过滤出需要更新的某行，更新versionNum
                            let update = data.update(versionNum <- " ")
                            do {
                                let num = try db.run(update)
                                print("更新数量：\(num)")
                            } catch {
                                print(error)
                            }
                        }
                    }else {
                        Logger.debug("数据不为空")
                    }
                }
            } catch{
                createdsqlite3()
                print("出错: \(error)")
            }
        }
        
    }
    
    // MARK: 创建数据库文件
    mutating func createdsqlite3() {
        do {
            try db.run(testSQLTable.create(block: { (table) in
                table.column(id, primaryKey: true)
                table.column(type)
                table.column(titlename)
                table.column(identifier)
                table.column(detail)
            }))
            print("创建数据库成功")
        } catch {
            print("创建数据库出错: \(error)")
        }
    }
    
    // MARK: 添加
    func insert(scanDbModel: AppIconModel){
        let insert = testSQLTable.insert(
            type <- scanDbModel.type,
            titlename <- scanDbModel.titlename,
            identifier <- scanDbModel.identifier,
            detail <- scanDbModel.detail)
        do {
            let sqlFileid = try db.run(insert)
            print("添加成功 sqlFileidID：\(sqlFileid)")
        } catch {
            print("添加失败")
        }
    }
    
    // MARK: 删除
    func delete(identifiers: String) {
        let query = testSQLTable.filter(identifier == identifiers)
        do {
            let num = try db.run(query.delete())
            print("删除成功 id:\(num)")
        } catch {
            print("删除出错: \(error)")
        }
    }
    
    // MARK:  更新信息
    func updateData(identifierU: String, nameU: String) {
        let data = testSQLTable.filter(identifier == identifierU)
        let update = data.update(titlename <- nameU)
        do {
            let num = try db.run(update)
            print("更新成功 id:\(num)")
        } catch {
            print(error)
        }
    }
    
    // MARK: 查询所有数据
    func query() -> [AppIconModel] {
        var scanDbModelList = [AppIconModel]()
        //reversed()以倒序的方式添加新元素，新元素永远保持在首位
        for data in try! db.prepare(testSQLTable).reversed() {
            let scanDbModel = AppIconModel(type: data[type], titlename: data[titlename], identifier: data[identifier], peripheral: nil, product: Product.types(""), broadcastPacketAnalysis:  BroadcastPacketAnalysis.init(bytes: nil), scanPacketAnalysis: ScanPacketAnalysis.init(dataString: ""), offlineBool: false, visitime: "data[visitime]", detail: "data[detail]", searchtime: "data[searchtime]")
            scanDbModelList.append(scanDbModel)
        }
        
        return scanDbModelList
    }
    
}

