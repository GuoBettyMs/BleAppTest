//
//  MenuTableViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/7/6.
//

import UIKit

class MenuTableViewCell: UITableViewCell {



    @IBOutlet weak var menuCellImg: UIImageView!
    @IBOutlet weak var menuNameCellL: UILabel!
    @IBOutlet weak var menuPriceCellL: UILabel!
    
    
    var menu: Menu?{
        didSet{
            guard let menu = menu else {
                return
            }

            menuCellImg.image = UIImage(named: menu.menuImageName)
            menuNameCellL.text = menu.menuName
            menuPriceCellL.text = "¥\(menu.menuPrice)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
