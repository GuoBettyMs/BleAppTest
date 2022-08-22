//
//  TestCollectionViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/4/28.
//

import UIKit

class TestCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var collectionContentView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionContentView.layer.cornerRadius = 10
        
        
        
    }

}
