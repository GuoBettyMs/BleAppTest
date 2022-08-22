//
//  TestTableCellTableViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/4/24.
//

import UIKit

class TestTableViewCell: UITableViewCell {


    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var titlenameL: UILabel!
    @IBOutlet weak var visittimeL: UILabel!
    @IBOutlet weak var detailL: UILabel!
    @IBOutlet weak var searchL: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        customView.layer.masksToBounds = true
        customView.layer.cornerRadius = 20
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override var frame: CGRect {
            didSet {
                var newFrame = frame
                newFrame.size.height -= 3
                super.frame = newFrame
            }
        }
    
}
