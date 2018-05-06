//
//  RecipeDetailsTableCell.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/14/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class RecipeDetailsTableCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
