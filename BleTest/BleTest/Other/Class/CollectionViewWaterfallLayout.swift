//
//  TestWaterfallLayoutDelegate.swift
//  IOSApp
//
//  Created by gbt on 2022/4/27.
//

import UIKit

//自定义瀑布流类
protocol TestWaterfallLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
    
}

class CollectionViewWaterfallLayout: UICollectionViewFlowLayout {
    var columnCount = 2
    var columnSpacing: CGFloat = 4
    var lineSpacing: CGFloat = 4
    
    //为防止被循环使用，添加weak
    weak var delegate: TestWaterfallLayoutDelegate?    //delegate优先级最高
    
    var collectionViewContentWidth: CGFloat{
        
        guard let collectionView = collectionView else{ return  0}
        return  collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
    }
    var collectionViewContentHeight: CGFloat = 0
    

    override var collectionViewContentSize: CGSize{
        CGSize(width: collectionViewContentWidth, height: collectionViewContentHeight)
 
    }
    
    //所有cell的布局属性
    private var layoutAttributesArr: [UICollectionViewLayoutAttributes] = []
    
    //首次布局和更新布局时调用
    override func prepare() {
        super.prepare()
        
        //当更新布局时判断layoutAttributesArr 是否为空，若不是则返回无需进行下面的计算
        guard let collectionView = collectionView, layoutAttributesArr.isEmpty else{ return }
        
        let itemWidth = (collectionViewContentWidth - columnSpacing) / CGFloat(columnCount)    //列边距columnSpacing
        //计算出每一列cell的x坐标
        //列数为2时，x=[0, itemWidth * 1 + columnSpacing * 1]
        //列数为3时，x=[0, itemWidth * 1 + columnSpacing * 1, itemWidth * 2 + columnSpacing * 2]
        var x: [CGFloat] = []
        for column in 0..<columnCount{
            x.append((itemWidth + columnSpacing) * CGFloat(column))
        }
        
        var y: [CGFloat] = Array(repeating: 0, count: columnCount)  //等效于 var y: [CGFloat] = .init(repeating: 0, count: columnCount)
        var column = 0
        for item in 0..<collectionView.numberOfItems(inSection: 0){
            let indexPath = IndexPath(item: item, section: 0)
            let itemHight = delegate?.collectionView(collectionView, heightForItemAt: indexPath) ?? 100
            //得出每个cell的frame
            let itemFrame = CGRect(x: x[column], y: y[column], width: itemWidth, height: itemHight)
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)        //单个cell的布局属性
            layoutAttributes.frame = itemFrame
            layoutAttributesArr.append(layoutAttributes)
            collectionViewContentHeight = max(collectionViewContentHeight, itemFrame.maxY)
            
            //思路1.第二排开始，新的y坐标 = 旧的y坐标 + item高度 + item间距
            //思路2.假设共有2列，第一排排满后，第一排的y坐标是互不相等的。比较第一排的y坐标得到最小值，将新元素放置在最小值位置上，填满第二排剩余位置
            //思路3:第二排坐标覆盖掉第一排坐标，比较第二排的y坐标得到最小值，将新元素放置在最小值位置上，填满第三排剩余位置
            
            //更新y坐标数组y[]：新的y坐标 = 旧的y坐标 + item高度 + item间距
            y[column] = y[column] + itemHight + lineSpacing

            //更新column：y坐标为一个数组y[]，比较上一轮数组，得到最小值，新的y坐标以最小值为起始值
            //寻找上一轮数组的最小值y.min()，，使用firstIndex访问y.min()，确定y.min()属于哪一列，将这一列作为新的column
            //firstIndex(） 返回元素在数组中的索引
            column = y.firstIndex(of: y.min()!)!
            
            
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            //将相交的布局属性显示可视
        var visibleLayoutAtrributesArr: [UICollectionViewLayoutAttributes] = []

        for layoutAttributes in layoutAttributesArr{
            if layoutAttributes.frame.intersects(rect){
                visibleLayoutAtrributesArr.append(layoutAttributes)

            }
        }
        return visibleLayoutAtrributesArr
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //每次调用都给予一个布局属性
        layoutAttributesArr[indexPath.item]
    }
    
}
