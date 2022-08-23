//
//  JsonPasingViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/5/5.
//

import UIKit

class JsonPasingViewController: UIViewController, UITableViewDataSource {
    
    //private,表示变量tableView只能用在JsonPasingViewController
    //lazy，表示只有在使用到UITableView控件时，才能用到后面的代码,若不添加lazy，表示在使用JsonPasingViewController时也会调用UITableView的代码，造成加载速度慢
    //懒加载必须定义为变量，实力化对象后才执行代码，此时才有初始值，常量属性需要在实例化前就有初始值
    //闭包，表示执行填充的多行代码
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var courses: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
//        let backButton = UIButton(frame: CGRect(x: 100, y: 100, width: 60, height: 30))
//        self.view.addSubview(backButton)
//        backButton.setTitle("返回", for: .normal)
//        backButton.setTitleColor(.white, for: .normal)
//        backButton.backgroundColor = .blue
//        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        loadData()
        view.addSubview(tableView)
        setUI()
        
        
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courses.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
//        var contentConfig = cell.defaultContentConfiguration()
//        contentConfig.text = courses[indexPath.row].title
//        cell.contentConfiguration = contentConfig
        cell.course = courses[indexPath.row]
        
        return cell
    }
    
//
//    @objc func back(){
//        dismiss(animated: true)
//    }


}

extension JsonPasingViewController{
    
    //调用json数据
    func loadData(){
        if let coursesJSONURL = Bundle.main.url(forResource: "courses", withExtension: "json"){
            if let courseJSONData = try? Data(contentsOf: coursesJSONURL){
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do{
                    courses = try decoder.decode([Course].self, from: courseJSONData)
                }catch{
                    print("解析json数据失败，原因是:\(error)")
                }
            }else{
                print("url转化Data失败")
            }
        }else {
            print("从courses.json文件中取url失败，检查拼写等")
        }
    }
    
    //增加约束
    func setUI(){
        
        //相对于safeArea，增加约束view.safeAreaLayoutGuide.topAnchor
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //相对于整个view，增加约束
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
    
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        let x = screenEdgePan.translation(in: view).x
        Logger.debug("点击了\(x)")
        
        dismiss(animated: true)
    }
    
}
