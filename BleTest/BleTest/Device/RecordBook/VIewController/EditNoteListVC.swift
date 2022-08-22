//
//  EditNoteListVC.swift
//  IOSApp
//
//  Created by gbt on 2022/7/13.
//

import UIKit
import SnapKit

class EditNoteListVC: UIViewController {

    var noteModel: RecordModel?
    var titleTextField: UITextField?
    var bodyTextView: UITextView?
    var group: String?
    var isNew = false               //是否是新的记事
    
    var bgImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()          //消除导航栏对布局的影响
        self.title = "编辑记事"
        
        bgImageView = UIImageView.init(frame: UIScreen.main.bounds)
        bgImageView = UIImageView(image: UIImage(named: "2"))
        self.view.addSubview(bgImageView)

        
        //监听键盘事件,防止键盘挡住用户输入的视线，进行重新布局
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardBeShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardBeHidden), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        installUI()
        installNavigationItem()
    }
    
    // MARK: 进行导航功能按钮的加载
    func installNavigationItem(){
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        self.navigationItem.rightBarButtonItems = [saveItem, deleteItem]
    }
    
    // MARK: 保存记事
    @objc func saveNote(){
        if isNew{
            if titleTextField?.text != nil && titleTextField!.text!.count>0{
                noteModel = RecordModel()
                noteModel?.title = titleTextField?.text!
                noteModel?.body = bodyTextView?.text
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                noteModel?.time = dateFormatter.string(from: Date())
                noteModel?.group = group
                RecordBookDataManager.addNote(note: noteModel!)                     //若为新建记事，数据库添加新记事
                self.navigationController!.popViewController(animated: true)
            }
        }else{
            if titleTextField?.text != nil && titleTextField!.text!.count>0{
                noteModel?.title = titleTextField?.text!
                noteModel?.body = bodyTextView?.text
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                noteModel?.time = dateFormatter.string(from: Date())
                RecordBookDataManager.updateNote(note: noteModel!)                     //若不是新建记事，数据库更新记事
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
 
    // MARK: 删除记事
    @objc func deleteNote(){
        let alertController = UIAlertController(title: "警告", message: "是否确定删除此记事?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "删除", style: .default, handler: {_ in
            if !self.isNew{
                RecordBookDataManager.deleteNote(note: self.noteModel!)
                self.navigationController!.popViewController(animated: true)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true)
    }

    // MARK: 进行界面加载
    func installUI(){
        titleTextField = UITextField()
        self.view.addSubview(titleTextField!)
        titleTextField?.borderStyle = .none
        titleTextField?.placeholder = "请输入记事标题"
        titleTextField?.snp.makeConstraints{ make in
            make.top.equalTo(30)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(30)
        }
        
        let lineView = UIView()
        self.view.addSubview(lineView)
        lineView.backgroundColor = .gray
        lineView.snp.makeConstraints{ make in
            make.top.equalTo(titleTextField!.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        bodyTextView = UITextView()
        bodyTextView?.layer.borderColor = UIColor.gray.cgColor
        bodyTextView?.backgroundColor = .clear
        bodyTextView?.layer.borderWidth = 0.5
        self.view.addSubview(bodyTextView!)
        bodyTextView?.snp.makeConstraints{ make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.bottom.equalTo(-30)
        }
        
        bgImageView.snp.makeConstraints{ make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        //当用户编辑已有的记事，记事原本的标题和内容需填充在编辑界面的响应位置
        if !isNew{
            titleTextField?.text = noteModel?.title
            bodyTextView?.text = noteModel?.body
        }
        
    }
    
    // MARK: 键盘出现时调用
    @objc func keyBoardBeShow(notification: Notification){
        let userInfo = notification.userInfo!
        //获取键盘的矩形框架
        let frameInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject
        let height = frameInfo.cgRectValue.size.height          //获取键盘高度
        
        //布局更新
        bodyTextView?.snp.updateConstraints { make in
            make.bottom.equalTo(-30-height)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    // MARK: 键盘消失时调用
    @objc func keyBoardBeHidden(notificatworkion: Notification){
        bodyTextView?.snp.updateConstraints{ (make) in
            make.bottom.equalTo(-30)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: 当用户点击屏幕非文本区域时，进行收键盘操作
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bodyTextView?.resignFirstResponder()
        titleTextField?.resignFirstResponder()
    }
    
    // MARK: 在析构方法中移除通知的监听
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
