//
//  TestCollectionViewController.swift
//  IOSApp
//
//  Created by gbt on 2022/4/28.
//

import UIKit

private let reuseIdentifier = "Cell"
private let collectionViewContentInset = UIEdgeInsets(top:10, left:4, bottom:10, right:4)

class TestCollectionViewController: UICollectionViewController {

    var itemWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInset = collectionViewContentInset
        let layout = collectionView.collectionViewLayout as! CollectionViewWaterfallLayout
        itemWidth = (collectionView.bounds.width - collectionViewContentInset.left - collectionViewContentInset.right - layout.columnSpacing) / CGFloat(layout.columnCount)
        layout.delegate = self
        
        
//        //自带UICollectionViewFlowLayout
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.minimumInteritemSpacing = collectionViewContentInset.left
//        layout.minimumLineSpacing = collectionViewContentInset.left
//        let iteWidth = (collectionView.bounds.width - collectionViewContentInset.left * (2 + 1 )) / 2
//        layout.itemSize = CGSize(width: iteWidth, height: iteWidth)
        
    }


    @IBAction func BackAction(_ sender: Any) {
        dismiss(animated: true)
    }
    

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TestCollectionViewCell
        cell.imgView.image = UIImage(named: "\(indexPath.item + 1)")
    
        return cell
    }

}



extension TestCollectionViewController: TestWaterfallLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat{
       //总高度为img高度+label高度+间距
        let imageSize = UIImage(named: "\(indexPath.item + 1)")!.size
        let imageWidth = imageSize.width
        let imageHight = imageSize.height
        //等比例缩放图片 imageRatio
        let imageRatio = imageHight / imageWidth
        return itemWidth * imageRatio + 41      //上下边距 + label高度 = 41
    }
}
