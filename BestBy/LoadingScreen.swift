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

//var realNames:[String] = ["apples","asparagus","avocados","bananas","blueberries","broccoli","butter","butter lettuce","butternut squash","carrots","cauliflower","celery","corn","cucumber","eggs","fingerling potatoes","grapes","green beans","green bell peppers","iceburg lettuce","kale","leaf lettuce","lemons","limes","milk","mushrooms","onions","orange bell peppers","oranges","peaches","pears","pineapples","pomegranates","red bell peppers","red potatoes","romaine lettuce","russet potatoes","sour cream","spaghetti squash","strawberries","summer squash","sweet potatoes","tomatoes","watermelon","white potatoes","winter squash","yellow bell peppers","yogurt","yukon gold potatoes","zucchini"]
//
//var img_names:[String] = ["apple-1.png","asparagus.png","avocado.png","banana.png","blueberries.png","broccoli.png","butter.png","cabbage.png","butternut-squash.png","carrot.png","cauliflower.png","chives.png","corn.png","cucumber.png","eggs.png","potatoes-2.png","grapes.png","peas.png","pepper.png","cabbage.png","salad-1.png","salad-1.png","lemon-1.png","lime.png","milk-1.png","mushroom.png","onion-1.png","bell-pepper-red.png","orange.png","peach.png","pear.png","pineapple.png","pmegranate.png","bell-pepper-red.png","potatoes-2.png","salad-1.png","potatoes-2.png","dairy.png","butternut-squash-1.png","strawberry.png","butternut-squash-1.png","potatoes-2.png","tomato.png","watermelon.png","potatoes-2.png","butternut-squash.png","pepper-yellow.png","yogurt.png","potatoes-2.png","cucumber.png"]

var x = [String:String]()
let group = DispatchSemaphore(value: 0)
let everySingleFoodLoaded = DispatchSemaphore(value: 0)

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var done = false;
    var i = 0;
    var childAddedSema = DispatchSemaphore(value: 0)
    
    
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
                                           t: foodInfo["timestamp"] as! Int)
                added.insert(key)
                
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
                                               t: foodInfo["timestamp"] as! Int)
                    
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
