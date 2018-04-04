//
//  LoadingScreen.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/4/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var x = [String:String]()
let group = DispatchSemaphore(value: 0)
let everySingleFoodLoaded = DispatchSemaphore(value: 0)

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var done = false;
    var i = 0;
    var childAddedSema = DispatchSemaphore(value: 0)
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadEverySingleFood() {
        i = 0
        let allFoodRef: DatabaseReference = Database.database().reference().child("EverySingleFood")
        allFoodRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let newFood = snapshot.value as! [String:[String:Any]]
            for (key, value) in newFood {
                
                if let img = UIImage(named: value["img_name"] as! String){
                    FoodData.food_data[key] = (value["doe"] as! Int, value["desc"] as! String, img)
                    continue
                }
                FoodData.food_data[key] = (value["doe"] as! Int, value["desc"] as! String, UIImage(named: "groceries"))

                
            }
            everySingleFoodLoaded.signal()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //try! Auth.auth().signOut()
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                self.fillCurrentUserSingleton(user: user!)
                
                DispatchQueue.global(qos: .background).async {
                    group.wait()
                    everySingleFoodLoaded.wait()
                    everySingleFoodLoaded.wait()
                    DispatchQueue.main.async{
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as? MainViewController
                        self.present(vc!, animated: true, completion: nil)
                    }
                }
            }
            else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signinview") as? SignInViewController
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func fillCurrentUserSingleton (user: User) {
        let ref: DatabaseReference = Database.database().reference()
        
        currentUser.shared.ID = user.uid
        currentUser.shared.userRef = ref.child("Users/\(user.uid)")
        
        loadAllUsersFood()
        loadEverySingleFood()
        loadUsersExtraFood()
    }
    
    func loadUsersExtraFood() {
        let userRef: DatabaseReference = currentUser.shared.userRef!
        userRef.child("ExtraFoods").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                everySingleFoodLoaded.signal()
                return
            }
            let extraItems = snapshot.value as! [String : Int]
            for (item, doe) in extraItems {
                FoodData.food_data[item] = (doe, "", UIImage(named: "groceries"))
            }
            everySingleFoodLoaded.signal()
        })
    }
    
    func loadAllUsersFood() {
        let userRef: DatabaseReference = currentUser.shared.userRef!
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot)
            let userInfo = (snapshot.value as! [String:Any?])
            
            currentUser.shared.allFoodListID = userInfo["AllUsersFood"] as? String
            currentUser.shared.allSpaces[currentUser.shared.allFoodListID!] = FoodList()
            currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]!.name = "All"
            
            if (userInfo["Spaces"] != nil) {
                currentUser.shared.otherFoodListIDs = Array((userInfo["Spaces"] as! [String:String]).keys)
                var i = 0
                for listID in currentUser.shared.otherFoodListIDs {
                    currentUser.shared.allSpaces[listID] = FoodList()
                    currentUser.shared.allSpaces[listID]?.name = Array((userInfo["Spaces"] as! [String:String]).values)[i]
                    i+=1
                }
            }
            
            if (userInfo["ShoppingLists"] != nil) {
                currentUser.shared.shoppingListIDs = Array((userInfo["ShoppingLists"] as! [String:String]).keys)
                var j = 0
                for shoppingListID in currentUser.shared.shoppingListIDs {
                    currentUser.shared.allShoppingLists[shoppingListID] = ShoppingList()
                    currentUser.shared.allShoppingLists[shoppingListID]?.name = Array((userInfo["ShoppingLists"] as! [String:String]).values)[j]
                    j+=1
                }
                self.observeEachShoppingList()
            }
            
            self.observeAllList(at: currentUser.shared.allFoodListID!)
        })

    }
    
    func observeEachShoppingList() {
        for shoppingListID in currentUser.shared.shoppingListIDs {
            let ref: DatabaseReference = Database.database().reference().child("AllShoppingLists/\(shoppingListID)")
            ref.observe(.childAdded, with: {snapshot in
                let foodInfo = snapshot.value as! String
                if snapshot.key != "name" {
                    let newListItem = ListItem(id: snapshot.key,
                                               n: foodInfo)
                    currentUser.shared.allShoppingLists[shoppingListID]!.contents.append(newListItem)
                }
            })
        }
    }
    func observeAllList(at: String) {
        let ref: DatabaseReference = Database.database().reference().child("AllFoodLists/\(at)")
        var added: Set<String> = []
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                group.signal()
                self.childAddedSema.signal()

                return
            }
            let allFoods = snapshot.value as! [String : [String : Any]]
            
            for (key, foodInfo) in allFoods {
                print("info: \(foodInfo)")
                
                let newFoodItem = FoodItem(id: key,
                                           n: foodInfo["name"] as! String,
                                           t: foodInfo["timestamp"] as! Int,
                                           space_id: foodInfo["spaceID"] as! String)
                added.insert(key)
                
                if (newFoodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400 < 1 {
                    Database.database().reference().child("AllFoodLists/\(at)/\(snapshot.key)").removeValue()
                    
                    continue
                }
                if (foodInfo["spaceName"] as! String != "All") {
                    currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]!.contents.append(newFoodItem)
                    
                    currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]!.contents.sort() {
                        $0.timestamp < $1.timestamp
                    }
                }
                
                currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.contents.append(newFoodItem)
                currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.name = foodInfo["spaceName"] as? String
                
                currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.contents.sort() {
                    $0.timestamp < $1.timestamp
                }
            }
        
            group.signal()
            self.childAddedSema.signal()
        })
        
        DispatchQueue.global(qos: .background).async {
            self.childAddedSema.wait()
            ref.observe(.childAdded, with: {snapshot in
                let foodInfo = snapshot.value as! [String:Any]
                print("info: \(foodInfo)")

                if(!added.contains(snapshot.key)) {
                    let newFoodItem = FoodItem(id: snapshot.key,
                                               n: foodInfo["name"] as! String,
                                               t: foodInfo["timestamp"] as! Int,
                                               space_id: foodInfo["spaceID"] as! String)
                    
                    if (newFoodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400 < 1 {
                        Database.database().reference().child("AllFoodLists/\(at)/\(snapshot.key)").removeValue()
                        return
                    }
                    if (foodInfo["spaceName"] as! String != "All") {
                        currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]!.contents.append(newFoodItem)
                        
                        currentUser.shared.allSpaces[currentUser.shared.allFoodListID!]!.contents.sort() {
                            $0.timestamp < $1.timestamp
                        }
                    }
                    
                    currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.contents.append(newFoodItem)
                    currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.name = foodInfo["spaceName"] as? String
                    
                    currentUser.shared.allSpaces[foodInfo["spaceID"] as! String]!.contents.sort() {
                        $0.timestamp < $1.timestamp
                    }
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        //Database.database().reference().removeAllObservers()
        //Database.database().reference().child("AllFoodLists/\(currentUser.shared.allFoodListID!)").removeAllObservers()
        //currentUser.shared.userRef!.removeAllObservers()
    }
    
}
