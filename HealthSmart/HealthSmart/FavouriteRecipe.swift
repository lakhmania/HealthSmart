//
//  FavouriteRecipe.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/13/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class FavouriteRecipe: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
