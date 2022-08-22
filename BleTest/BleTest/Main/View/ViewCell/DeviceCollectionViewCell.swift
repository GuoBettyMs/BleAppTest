//
//  DeviceCollectionViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/4/24.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgnameL: UILabel!
    @IBOutlet weak var statusL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        customView.layer.cornerRadius = 20
        
        imgnameL.numberOfLines = 0
        imgnameL.lineBreakMode = .byWordWrapping
        
  
    }

}
