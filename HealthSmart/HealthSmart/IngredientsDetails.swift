//
//  IngredientsDetails.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/22/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class IngredientsDetails: UITableViewCell {

  
    @IBOutlet weak var ingName: UILabel!
    
    @IBOutlet weak var ingQuantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
