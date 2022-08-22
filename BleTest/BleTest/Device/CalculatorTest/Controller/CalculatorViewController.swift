//
//  CalculatorViewController.swift
//  IOSApp
//
//  Created by isdt on 2022/3/7.
//

import UIKit
import RxSwift
import RxCocoa

//BaseobjectViewController<Container: UIView>为基础视图控制器，其中Container为基础视图控制器的主视图，可使用Container.来调用主视图的控件与方法
//CalculatorViewController: BaseobjectViewController<CalculatorView>，子视图控制器继承BaseobjectViewController内容，且在CalculatorViewController中可用Container.来调用CalculatorView里面的控件与方法
class CalculatorViewController: BaseobjectViewController<CalculatorView>{

    var disposeBag = DisposeBag()
    let calculatorengine = Calculatorengine()
    
    var shareButton = UIButton()
    var controller: UIActivityViewController?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        controller?.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2, width: 0, height: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        shareButton = UIButton(frame: CGRect(x: 100, y: 100, width: 150, height: 130))
        shareButton.backgroundColor = UIColor.black
        shareButton.setTitle("BUTTON", for: .normal)
        shareButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        self.view.addSubview(shareButton)
        
 
        installUI()
        
    }
    
    
    
    @objc func click(){

        controller = UIActivityViewController(activityItems: ["hello world"], applicationActivities: nil)
        
        let pop = controller?.popoverPresentationController
        pop?.sourceView = self.view
//        pop?.sourceRect = self.view.bounds
        pop?.sourceRect = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2, width: 0, height: 0)
        pop?.permittedArrowDirections = []
        
        
        self.present(controller!, animated: true, completion: nil)
        
        print("click")
        
    }

    
    func installUI(){

        for i in 0...19 {
            container.boardView.buttonArray[i].rx.tap
                .subscribe(onNext:{[weak self] in
                    guard let selfs = self else{
                        return
                    }
                    
                    let content : String = selfs.container.boardView.buttonArray[i].currentTitle!
                    print(content)
                    
                    if content == "AC" || content == "Del" || content == "=" {
                        switch content{
                        case "AC":
                            selfs.container.screenView.clearcontent()
            //                selfs.container.screenView.refreshhistory()
                            selfs.container.screenView.inputLabel?.text = "0"
                        case "Del":
                            selfs.container.screenView.deletelastinput()
                        case "=":
                            
                            if selfs.container.screenView.figureArray.contains(selfs.container.screenView.inputstring.last!) {
                                let result = selfs.calculatorengine.calculatorequation(equation: selfs.container.screenView.inputstring)
                                selfs.container.screenView.refreshhistory()
                                selfs.container.screenView.clearcontent()
                                selfs.container.screenView.inputcontent(content: String(result))
                                selfs.calculatorengine.isneedfresh = true
                            }


                        default:
                            selfs.container.screenView.refreshhistory()
                        }
                    }else{
                        if selfs.calculatorengine.isneedfresh{
                            selfs.container.screenView.clearcontent()
                            selfs.calculatorengine.isneedfresh = false
                        }
                        selfs.container.screenView.inputcontent(content: content)

                    }
                    
                }).disposed(by: disposeBag)
            
        }

    }
    
    
    
    
    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}



