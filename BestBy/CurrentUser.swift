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
    
    //every food the user has
    var allFoodListID: String?
    var allFood: [String] = [String]()
    
    //all the shopping list IDs
    var allShoppingLists: [String:[String]]?
    
    //current space ID, "" or nil if a space isnt selected
    var currentSpace: String?
    var allSpaces: [(String , String)] = [(String,String)]()    //all the spaces the user has
    var foodBySpaces: [String: [FoodItem]] = [String: [FoodItem]]()
    
    func clear() {
        ID = nil
        userRef = nil
        allFood.removeAll()
    }
    
}
