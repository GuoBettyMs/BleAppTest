//
//  RecordBookVC.swift
//  IOSApp
//
//  Created by gbt on 2022/7/12.
//

import UIKit
import RxSwift
import RxCocoa

class RecordBookVC: BaseobjectViewController<RecordBookView>, HomeButtonDelegate {

    var disposeBag = DisposeBag()
    var dataArray: Array<String>?
    @IBOutlet weak var musicButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarColor(backgroundColor: .orange, titleColor: UIColor.init(named: "NaviBGColor")!)
        self.title = "点滴生活"
        
        //取消导航栏对页面布局的影响,视图将自动空出导航栏的位置
        self.edgesForExtendedLayout = UIRectEdge()

        container.homeButtonDelegate = self
        
        //读取用户的音频设置状态
        if MusicUserInfoManager.getAudioState(){
            musicButton.setTitle("音效：开", for: .normal)
            MusicEngine.shareInstance.playBackgroundMusic()
        }else{
            musicButton.setTitle("音效：关", for: .normal)
            MusicEngine.shareInstance.stopBackgroundMusic()
        }
        
        
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)

    }

    // MARK: 音效设置
    @IBAction func musicPlayer(_ sender: Any) {
        if MusicUserInfoManager.getAudioState(){
            musicButton.setTitle("音效：关", for: .normal)
            MusicUserInfoManager.setAudioState(isOn: false)
            MusicEngine.shareInstance.stopBackgroundMusic()
        }else{
            musicButton.setTitle("音效：开", for: .normal)
            MusicUserInfoManager.setAudioState(isOn: true)
            MusicEngine.shareInstance.playBackgroundMusic()
        }
    }
    // MARK: 增加新的分组
    @IBAction func addGroup(_ sender: Any) {
        let alertController = UIAlertController(title: "添加记事分组", message: "添加的分组名不能与已有组名重复或为空", preferredStyle: .alert)
        alertController.addTextField{ (textField) in
            textField.placeholder = "请输入记事分组名称"
        }
        
        let alertCancelItem = UIAlertAction(title: "取消", style: .cancel, handler: {(UIAlertAction) in
            return
        })
        let alertConfirmItem = UIAlertAction(title: "确定", style: .default, handler: {(UIAlertAction) -> Void in
            var exist = false
            
            self.dataArray?.forEach({ (element) in
                if element == alertController.textFields?.first!.text || alertController.textFields?.first!.text?.count == 0 {
                    exist = true
                }
            })
            if exist{ return }

            self.dataArray?.append(alertController.textFields!.first!.text!)
            self.container.groupTitleArray = self.dataArray!
            self.container.scrollViewUpdateLayout()
            
            //将添加的分组写入到数据库
            RecordBookDataManager.saveGroup(name: alertController.textFields!.first!.text!)
        })
        alertController.addAction(alertCancelItem)
        alertController.addAction(alertConfirmItem)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: 分组的协议事件
    func homeButtonClick(title: String) {
        //在 RecordBookView 文件中，根据btn.tag 得到groupTitleArray数组中的某个值，并作为分组视图的title
        let controller = NoteListTableVC()
        controller.name = title 
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataArray = RecordBookDataManager.getGroupData()            //从数据库获取分组数据
        container.groupTitleArray = dataArray!
        container.scrollViewUpdateLayout()
    }
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        _ = screenEdgePan.translation(in: view).x
        MusicEngine.shareInstance.stopBackgroundMusic()
        dismiss(animated: true)
    }
    
    
}
