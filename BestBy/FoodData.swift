//
//  FoodData.swift
//  BestBy
//
//  Created by Erin Jensby on 2/18/18.
//
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

struct FoodData {
    static var food_data:[String:(Int,String, UIImage?)] = [:]
}

class FoodItem {
    var ID: String
    var name: String
    var timestamp: Int
    var spaceID: String
    
    init(id: String, n: String, t: Int, space_id: String ) {
        ID = id
        name = n
        timestamp = t
        spaceID = space_id
    }
    
    static func ==(lhs: FoodItem, rhs: FoodItem) -> Bool {
        return (lhs.ID == rhs.ID)
    }
}

class FoodList {
    var name: String?
    var contents: [FoodItem] = []
}

class ListItem {
    var ID: String
    var name: String
    
    init(id: String, n: String) {
        ID = id
        name = n
    }
    
    static func ==(lhs: ListItem, rhs: ListItem) -> Bool {
        return (lhs.ID == rhs.ID)
    }
}

class ShoppingList {
    var name: String?
    var contents: [ListItem] = []
}
