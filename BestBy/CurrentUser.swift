//
//  CurrentUser.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/16/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import UIKit

class currentUser {
    var ID: String?
    var allFood: [Food]?
    
    init(uid: String) {
        ID = uid
    }
    
    
}

class Food {
    var foodName: String
    var daysToExpire: Int
    var foodImage: UIImage?
    var description: String
    
    init(name: String) {
        self.foodName = name
        self.daysToExpire = 30
        self.description = "This finna expire and turn green"
    }
    func toAnyObject() -> Any {
        return [
            "name": foodName,
            "daysToExpire": daysToExpire,
            "desc": description
        ]
    }
}
