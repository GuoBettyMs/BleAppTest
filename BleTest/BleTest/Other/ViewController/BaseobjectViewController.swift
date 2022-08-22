//
//  BaseobjectViewController.swift
//  IOSApp
//
//  Created by isdt on 2022/3/8.
//

import UIKit
import NVActivityIndicatorView


class BaseobjectViewController<Container: UIView>: UIViewController {

    var container: Container { view as! Container }
    var cellDataAction: AppIconModel? = nil
    
    //uiviewcontroller的view被创建完成后，调用该方法
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    /*  访问uiviewcontroller的view时，当view为nil，该方法被调用，并会创建一个空白view赋值给
     uiviewcontroller的view属性，即可通过重写该方法来自定义uiviewcontroller的view属性   */
    //PS：若需要自定义uiviewcontroller的view，只需重写loadview 方法，无需调用
    override func loadView() {
        super.loadView()
        if view is Container {
//            Logger.debug("BaseViewControllerBaseViewControllerBaseViewControllerBaseViewController")

            if cellDataAction == nil {
//                Logger.debug("BasecellDataActioncellDataActioncellDataActioncellDataActioncellDataActioncellDataAction")
                
            }
            return
        }
        view = Container()
    }


    // MARK: 设置导航栏
    func navigationBarColor(backgroundColor: UIColor, titleColor: UIColor) {
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : titleColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)
            ]
            navigationController!.navigationBar.standardAppearance = appearance
            navigationController!.navigationBar.scrollEdgeAppearance = navigationController!.navigationBar.standardAppearance
        } else {
            navigationController!.navigationBar.barTintColor = backgroundColor
            navigationController!.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : titleColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize:22)
            ]
            navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController!.navigationBar.shadowImage = UIImage()
            navigationController!.navigationBar.layoutIfNeeded()
        }
        
//        guard cellDataAction != nil else {
//            dismiss(animated: true, completion: nil)
//            return
//        }
//        navigationItem.title = cellDataAction!.name
        
    }
    
}
