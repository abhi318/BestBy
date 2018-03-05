//
//  CurrentUser.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/16/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Firebase
import FirebaseDatabase
import UIKit

//Singleton of Current User
final class currentUser {
    
    // Can't init is singleton
    private init() {
        
    }
    
    // MARK: Shared Instance
    
    static let shared = currentUser()
    
    // MARK: Local Variable
    var ID: String?
    var userRef: DatabaseReference?
    var allFood: [String] = [String]()
    var allShoppingLists: [String:[String]]?
    var currentListID: String?
    
    func clear() {
        ID = nil
        userRef = nil
        allFood.removeAll()
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
