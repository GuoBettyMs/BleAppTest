//
//  NoteListTableViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/7/13.
//

import UIKit

class NoteListTableVC: UITableViewController {
    
    var recordModelArray :[RecordModel] = []
    var name : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = name
          
        var bgImageView = UIImageView.init(frame: self.view.bounds)
        bgImageView = UIImageView(image: UIImage(named: "2"))
        self.tableView.backgroundView = bgImageView

        installNavigationItem()
    }
    
    func installNavigationItem(){
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteGroup))
        self.navigationItem.rightBarButtonItems = [addItem, deleteItem]
    }
    
    // MARK: 添加新的记事
    @objc func addNote(){
        let editNoteListVC = EditNoteListVC()
        editNoteListVC.group = name!
        editNoteListVC.isNew = true
        self.navigationController?.pushViewController(editNoteListVC, animated: true)
        
    }
 
    // MARK: 删除所在的分组
    @objc func deleteGroup(){
        let alertController = UIAlertController(title: "警告", message: "是否确定删除此分组及该分组所有记事?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "删除", style: .default, handler: {_ in
            RecordBookDataManager.deleteGroup(name: self.name!)
            self.navigationController!.popViewController(animated: true)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true)
    }
    
    // MARK: 每次出现列表界面时刷新数据
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordModelArray = RecordBookDataManager.getNote(group: name!)         //从数据库中获取记事
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recordModelArray.count
    }

    // MARK: 设置每个cell的内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "noteListCellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
           
        let model = recordModelArray[indexPath.row]
        cell?.backgroundColor = .clear
        cell?.textLabel?.text = model.title
        cell?.detailTextLabel?.text = model.time
        cell?.accessoryType = .disclosureIndicator

        return cell!
    }

    // MARK: 某个cell的点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)            //取消当前cell的选中状态
        
        //跳转到编辑记事界面
        let editNoteListVC = EditNoteListVC()
        editNoteListVC.group = name!
        editNoteListVC.isNew = false
        editNoteListVC.noteModel = recordModelArray[indexPath.row]
        self.navigationController?.pushViewController(editNoteListVC, animated: true)
    }

}
