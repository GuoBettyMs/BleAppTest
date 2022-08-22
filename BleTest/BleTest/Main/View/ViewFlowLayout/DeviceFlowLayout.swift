//
//  DeviceFlowLayout.swift
//  IOSApp
//
//  Created by gbt on 2022/4/22.
//

import UIKit


class DeviceFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        setuplayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setuplayout()
    }

    func setuplayout() {
        minimumInteritemSpacing = 4
        minimumLineSpacing = 10
        scrollDirection = .vertical
    }

    override var itemSize: CGSize {
        set {

        }
        get {
            var numberOfColumns: CGFloat = 0
                numberOfColumns = 2
            let itemWidth = (self.collectionView!.frame.width - 10 * (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: itemWidth, height: 145)
        }
    }

}
