//
//  CategoryTableViewCell.swift
//  IOSApp
//
//  Created by gbt on 2022/7/6.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {


    @IBOutlet weak var categoryCellL: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? .systemBackground : .clear
        categoryCellL.font = selected ? .boldSystemFont(ofSize: 15) : .systemFont(ofSize: 15)
        categoryCellL.textColor = selected ? .label : .secondaryLabel
    }

    
    
    
}
