//
//  ShoppingListCellTableViewCell.swift
//  BestBy
//
//  Created by Erin Jensby on 2/28/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class ShoppingListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var newListTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
