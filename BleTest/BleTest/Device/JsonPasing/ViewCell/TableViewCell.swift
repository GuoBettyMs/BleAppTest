//
//  TableViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/5/5.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    private lazy var titleL: UILabel = {
        let titleL = UILabel()
        titleL.font = .systemFont(ofSize: 22)
//        titleL.text = "jsonPasing-IOS开发"      //静态数据
        return titleL
    }()

//    private lazy var serviceButton: UIButton = {
//        let serviceButton = UIButton()
//        serviceButton.setTitle("永久保留", for: .normal)
//        serviceButton.titleLabel?.font = .systemFont(ofSize: 15)
//        serviceButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
//        serviceButton.backgroundColor = UIColor(named: "BGColor")
//        serviceButton.layer.cornerRadius = 5        //将圆角半径设置为一半，最终呈现出圆形
//        serviceButton.clipsToBounds = true
//       return serviceButton
//    }()
//
//    private lazy var serviceButton1: UIButton = {
//        let serviceButton = UIButton()
//        serviceButton.setTitle("实时更新", for: .normal)
//        serviceButton.titleLabel?.font = .systemFont(ofSize: 15)
//        serviceButton.setTitleColor(UIColor(named: "TextColor"), for: .normal)
//        serviceButton.backgroundColor = UIColor(named: "BGColor")
//        serviceButton.layer.cornerRadius = 5        //将圆角半径设置为一半，最终呈现出圆形
//        serviceButton.clipsToBounds = true
//       return serviceButton
//    }()
    
    private lazy var serviceButtonStackView: UIStackView = {
//        let serviceButtonStackView = UIStackView(arrangedSubviews: [serviceButton, serviceButton1])
        let serviceButtonStackView = UIStackView()
        serviceButtonStackView.axis = .horizontal
        serviceButtonStackView.distribution = .fillProportionally
        serviceButtonStackView.spacing = 5
        return serviceButtonStackView
    }()

    private lazy var lessonCountL: UILabel = {
        let lessonCountL = UILabel()
        lessonCountL.font = .systemFont(ofSize: 15)
        lessonCountL.textColor = .secondaryLabel
//        lessonCountL.text = "199"     //静态数据
        return lessonCountL
    }()
    
    private lazy var courseStackView: UIStackView = {
        let courseStackView = UIStackView(arrangedSubviews: [titleL, serviceButtonStackView, lessonCountL])
        courseStackView.axis = .vertical
        courseStackView.alignment = .leading
        courseStackView.spacing = 6
        courseStackView.translatesAutoresizingMaskIntoConstraints = false
        return courseStackView
    }()
    
    //初始化构造器
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(courseStackView)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置动态数据
    var course: Course?{
        didSet{
            guard let course = course else {
                return
            }
            
            titleL.text = course.title
            lessonCountL.text = "\(course.lessonCount)课时"
            
            for service in course.services {
                let button = UIButton()
                var attriTitle = AttributedString(service)      //按钮的副文本
                attriTitle.font = .systemFont(ofSize: 15)
                attriTitle.foregroundColor = UIColor(named: "TextColor")        //按钮文本的前景色相当于文本颜色
//                attriTitle.backgroundColor = .blue                              //按钮文本的背景色
                
                var config = UIButton.Configuration.tinted()    //按钮的属性
                config.background.backgroundColor = UIColor(named: "BGColor")
                config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 5, bottom: 4, trailing: 5)
                
                config.attributedTitle = attriTitle         //设置按钮属性的 title property为 attriTitle
                button.configuration = config               //设置按钮属性为 config
                
                serviceButtonStackView.addArrangedSubview(button)       //动态添加view，addArrangedSubview
            }
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}

extension TableViewCell{
    //增加约束
    func setUI(){
        courseStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        courseStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        courseStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        courseStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
}
