//
//  FoodData.swift
//  BestBy
//
//  Created by Erin Jensby on 2/18/18.
//
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation

struct FoodData {
    
    static var food_data:[String:(Int,String)] = [:]
        
    
}

class FoodItem {
    var ID: String
    var name: String
    var timestamp: Int
    
    init(id: String, n: String, t: Int ) {
        ID = id
        name = n
        timestamp = t
    }
    
    static func ==(lhs: FoodItem, rhs: FoodItem) -> Bool {
        return (lhs.ID == rhs.ID)
    }
}
