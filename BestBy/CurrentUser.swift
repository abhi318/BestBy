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
    var profile_img: UIImage?
    var userRef: DatabaseReference?
    
    //every food the user has
    var allFoodListID: String?
    var allFood: [FoodItem] = [FoodItem]()
    
    //all the shopping list IDs
    var allShoppingLists: [String:ShoppingList] = [String:ShoppingList]()
    var shoppingListIDs: [String] = [String]()
        
    func clear() {
        ID = nil
        userRef = nil
        allFoodListID = nil
        allShoppingLists.removeAll()
        shoppingListIDs.removeAll()
        allFood.removeAll()
    }
}
