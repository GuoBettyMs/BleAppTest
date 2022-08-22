//
//  CirecleView.swift
//  IOSApp
//
//  Created by isdt on 2022/4/7.
//

import UIKit

class CirecleView: UIView {

    //初始化填充颜色
    let progressRoundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    let progressBGRoundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()

    private let innerRoundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let outerRoundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let secondRoundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    //初始化路径颜色
    var innerRoundColor: UIColor? = UIColor.clear
    var secondRoundColor: UIColor? = UIColor.clear
    var outerRoundColor: UIColor? = UIColor.clear
    var progressRoundColor: UIColor? = UIColor.clear
    var progressBGRoundColor: UIColor? = UIColor.clear
    
    //初始化路径宽度
    var innerRoundWidth: CGFloat = 10
    var secondRoundWidth: CGFloat = 10
    var outerRoundWidth: CGFloat = 10
    var progressRoundWidth: CGFloat = 10          //进度条背景宽度与进度条一致

    var voltageL: UILabel? // 中心文本显示
    var connectIV = UIImageView(image: UIImage(named: "ConnectIcon"))
    var percentageL: UILabel?
    var electricityIV = UIImageView(image: UIImage(named: "ElectricityIcon"))
    
    
    //初始化路径进度
    var progress: CGFloat = 0.0 {
        didSet {
            if progress > 100 {
                progress = 100
            }else if progress < 0 {
                progress = 0
            }
            //oldValue： 在didSet中已经设定好的值，didSet为属性观察，可用于验证 oldValue
            if oldValue != progress {
                progressRoundLayer.strokeEnd = CGFloat(progress)/100.0

            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addlayer()
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func addlayer(){

        layer.addSublayer(progressBGRoundLayer)
        layer.addSublayer(progressRoundLayer)
        layer.addSublayer(outerRoundLayer)
        layer.addSublayer(secondRoundLayer)
        layer.addSublayer(innerRoundLayer)
        
    }
    
    //当参数发生变化时调用
    override func layoutSubviews() {
        super.layoutSubviews()

        let cricleX = frame.size.width / 2
        let cricleY = frame.size.height / 2

        let innerRoundPath = UIBezierPath(arcCenter: CGPoint(x: cricleX, y: cricleY), radius: (frame.size.width - progressRoundWidth*2 - innerRoundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        innerRoundLayer.path = innerRoundPath.cgPath
        innerRoundLayer.lineWidth = innerRoundWidth
        innerRoundLayer.strokeColor = innerRoundColor?.cgColor


        let secondRoundPath = UIBezierPath(arcCenter: CGPoint(x: cricleX, y: cricleY), radius: (frame.size.width - progressRoundWidth*2 - innerRoundWidth - secondRoundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        secondRoundLayer.path = secondRoundPath.cgPath
        secondRoundLayer.lineWidth = secondRoundWidth
        secondRoundLayer.strokeColor = secondRoundColor?.cgColor
//        secondRoundLayer.fillColor = screenpowercircle1Color



        let outerRoundPath = UIBezierPath(arcCenter: CGPoint(x: cricleX, y: cricleY), radius: (frame.size.width - progressRoundWidth*2 - innerRoundWidth - secondRoundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        outerRoundLayer.path = outerRoundPath.cgPath
        outerRoundLayer.lineWidth = outerRoundWidth
        outerRoundLayer.strokeColor = outerRoundColor?.cgColor
//        outerRoundLayer.fillColor = screenpowercircle1Color


        let progressRoundPath = UIBezierPath(arcCenter: CGPoint(x: cricleX, y: cricleY), radius: (frame.size.width - progressRoundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        progressRoundLayer.strokeEnd = CGFloat(progress)/100
        progressRoundLayer.path = progressRoundPath.cgPath
        progressRoundLayer.lineWidth = progressRoundWidth
        progressRoundLayer.strokeColor = progressRoundColor?.cgColor
//        progressRoundLayer.fillColor = progressRoundColor?.cgColor
//        setStrokeAnimation(duration: 2)

        let progressBGRoundPath = UIBezierPath(arcCenter: CGPoint(x: cricleX, y: cricleY), radius: (frame.size.width - progressRoundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        progressBGRoundLayer.path = progressBGRoundPath.cgPath
        progressBGRoundLayer.lineWidth = progressRoundWidth
        progressBGRoundLayer.strokeColor = progressBGRoundColor?.cgColor
//        progressRoundLayer.fillColor = screenpowercircle1Color


    }
    

    func setStrokeAnimation(duration time: TimeInterval) {

        let RoundstrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        RoundstrokeAnimation.fromValue = 0        //动画开始值
        RoundstrokeAnimation.toValue = 1          //动画结束绝对值，byvalue 动画结束相对值
        RoundstrokeAnimation.duration = time
        RoundstrokeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressRoundLayer.strokeEnd = 1.0
        progressRoundLayer.add(RoundstrokeAnimation, forKey: "")

    }
    
    // 动画的方法
    func animateCircle(duration t: TimeInterval) {
        // 画圆形，就是靠 `strokeEnd`
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // 指定动画时长
        animation.duration = t

        // 动画是，从没圆，到满圆
        animation.fromValue = 0
        animation.toValue = 1

        // 指定动画的时间函数，保持匀速
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // 视图具体的位置，与动画结束的效果一致
        //circleLayer.strokeEnd = 1.0

        // 开始动画
        //circleLayer.add(animation, forKey: "animateCircle")
    }
    
    
    // MARK: 设置进度条圆角
    func progresslineRound() {
        progressRoundLayer.lineCap = CAShapeLayerLineCap.round
    }
    
    // MARK: 设置进度条阴影
    func progressShadow() {
        progressRoundLayer.shadowOpacity = 0.2
        progressRoundLayer.shadowOffset = CGSize.zero
    }
    
    
    // MARK: 设置显示内容
    func setIsHiddenView(voltageBool: Bool, connectBool: Bool, percentageBool: Bool, electricityBool: Bool){
        voltageL?.isHidden = voltageBool
        connectIV.isHidden = connectBool
        percentageL?.isHidden = percentageBool
        electricityIV.isHidden = electricityBool
    }
    
    
    // MARK: 设置字体
    func setVoltageLUIFont(name: String, size: CGFloat) {
        voltageL!.font = UIFont(name: name, size: size)
    }
    func setPercentageLUIFont(name: String, size: CGFloat) {
        percentageL!.font = UIFont(name: name, size: size)
    }
    
    func setProgress(_ value: Int){
        
        progress = CGFloat(value)
    }
    
   
    //设置旋转角度
    func angleToRadian(_ angle: CGFloat) -> CGFloat{
        return .pi * (angle / 180)
    }
    
    //设置路径颜色
    func setStrokeColor(innerColor: UIColor, secondColor: UIColor, outerColor: UIColor, progressColor: UIColor, progressBGColor: UIColor){
        innerRoundColor = innerColor
        secondRoundColor = secondColor
        outerRoundColor = outerColor
        progressRoundColor = progressColor
        progressBGRoundColor = progressBGColor
        
        //        progressLayer.strokeColor = kProgressColor.cgColor
        //        progressBackgroundLayer.strokeColor = kProgressBackgroundColor.cgColor
        //        roundLayer.strokeColor = kRoundColor.cgColor
        //        roundLayer1.strokeColor = kRoundColor1.cgColor
        //        roundLayer2.strokeColor = kRoundColor2.cgColor
        //        roundLayer2.fillColor = kRoundColor2.cgColor
    }
    
    //设置路径宽度
    func setStrokeWidth(innerWidth: CGFloat, secondWidth: CGFloat, outerWidth: CGFloat, progressWidth: CGFloat){
        innerRoundWidth = innerWidth
        secondRoundWidth = secondWidth
        outerRoundWidth = outerWidth
        progressRoundWidth = progressWidth
        
        

        
    }
    
    
}
