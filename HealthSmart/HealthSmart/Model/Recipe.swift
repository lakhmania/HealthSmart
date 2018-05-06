//
//  Recipe.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/14/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import Foundation
import UIKit

class Recipe {
    var recipeId: Int!
    var recipeName: String!
    var ingridentsList: [String] = []
    var instruction : [String] = []
    var recipeImage: UIImage!
    var recipeRating: Int!
    var preparationMin: Int!
    var servings: Int!
    var imageUrl: String!
    
}
