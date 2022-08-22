//
//  TableViewTestVC.swift
//  IOSApp
//
//  Created by gbt on 2022/7/1.
//

import UIKit

let kCategoryCellID = "CategoryCellID"
let kMenuCellID = "MenuCellID"
let kMenuHeaderNibName = "MenuHeader"
let kMenuHeaderCellID = "MenuHeaderCellID"


class MenuTableVC: UIViewController {


    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var menuTableView: UITableView!
    
    var categories: [String] = []
    var menus: [[Menu]] = []
    
    var menuTableViewGoDown = true
    
    var menuTableViewCurrentContentOffsetY = 0.0       //ContentOffset = 0,0  可视内容,x:0, y:0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //给heaader 注册
        menuTableView.register(UINib(nibName: kMenuHeaderNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: kMenuHeaderCellID)
        
        for i in 1...20{
            categories.append("分类\(i)")
        }
     
        for category in categories {
            //每个种类对应一个菜单数组，存放多个菜单
            var menuCategory: [Menu] = []
            for i in 1...3{
                let menu = Menu(menuImageName: "summericons_100px_00", menuName: "\(category)-外卖菜品\(i)", menuPrice: Double(i))
                menuCategory.append(menu)
            }
            menus.append(menuCategory)
        }
        
        //默认让第一个cell是选中状态
        categoryTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        
        
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)
        
        
    }
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        _ = screenEdgePan.translation(in: view).x
        MusicEngine.shareInstance.stopBackgroundMusic()
        dismiss(animated: true)
    }
    
}


extension MenuTableVC: UITableViewDataSource{
    
    //第sction组有几行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == categoryTableView ? categories.count : menus[section].count
    }
    
    //indexPath 这行的cell长什么样
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryCellID, for: indexPath) as! CategoryTableViewCell
            cell.categoryCellL.text = categories[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: kMenuCellID, for: indexPath) as! MenuTableViewCell
            cell.menu = menus[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    //每个tableView有几组
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView == categoryTableView ? 1 : categories.count
    }
}


extension MenuTableVC: UITableViewDelegate{
    
    // MARK: 配置右侧的header
    //第section 组头部显示什么控件
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == categoryTableView{
            return nil
        }

        tableView.sectionHeaderTopPadding = 0       //将tableView的顶部padding 设置为 0
        let menuHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: kMenuHeaderCellID) as! MenuHeader
        menuHeader.menuHeaderNameL.text = categories[section]
        return menuHeader
    }
    
    //分类tableVIew 会默认出现一个无title 的header，需要指定高度才能消失
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView == categoryTableView ? 0 : 30
    }

    // MARK: 左侧cell被点击时，右侧cell联动
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoryTableView{
            //IndexPath： 通过行索引和节索引 标识 表视图中的行的索引路径
            //当categoryTableView索引路径标识到第2行时（categoryTableView 的indexPath为 indexPath.row），menuTableView 需要滚动到第2节的第一行，那么menuTableView的索引路径就是行索引： 0，节索引： 2（indexPath.row）
            menuTableView.scrollToRow(at: IndexPath(row: 0, section: indexPath.row), at: .top, animated: true)
            //左侧将被选中cell 滚动到顶部
            categoryTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    // MARK: 右侧cell被点击时，左侧cell联动
    //注： 当 menuTableView 向上滚动(手势往下，行数增加，1->20)时，且右侧cell被拖拽放开惯性结束后，才发生联动
    //判断menuTableView的滚动方向
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        if tableView == menuTableView{
            //当menuTableView 向上滚动(行数增加，1->20)时，tableView.contentOffset.y 会变小
            //当menuTableView 向下滚动(行数减少，20->1)时，tableView.contentOffset.y 会变大
            menuTableViewGoDown = menuTableViewCurrentContentOffsetY < tableView.contentOffset.y
            menuTableViewCurrentContentOffsetY = tableView.contentOffset.y      //更新当前tableView的位置
        }
    }
    
    //当 menuTableView 向上滚动(手势往下，行数增加，1->20)时，categoryTableView 显示对应的行索引
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
       //menuTableView.isDragging || menuTableView.isDecelerating ，右侧cell被拖拽或者减速
        if tableView == menuTableView && !menuTableViewGoDown && (menuTableView.isDragging || menuTableView.isDecelerating){
            //categoryTableView 只有一节，所以section = 0
            //当 menuTableView 滚动到第8行时（节索引为 7），categoryTableView 显示第7行（即被选中第7行），与节索引数值相等，所以row = section
            categoryTableView.selectRow(at: IndexPath(row: section, section: 0), animated: true, scrollPosition: .top)
        }
    }
    
    //当 menuTableView 向下滚动(手势往上，行数减少，20->1)时，menuTableView 隐藏某个节索引,categoryTableView显示被隐藏索引的下一个行索引
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if tableView == menuTableView && menuTableViewGoDown && (menuTableView.isDragging || menuTableView.isDecelerating){
            //假设menuTableView 向下滚动，menuTableView 隐藏了第7行，categoryTableView 也需要隐藏第7行，显示第8行（即被选中第8行）
            categoryTableView.selectRow(at: IndexPath(row: section+1, section: 0), animated: true, scrollPosition: .top)
        }
    }
}
