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
import FirebaseStorage

var gradient = [UIColor(red:0.75, green:0.9, blue:0.45, alpha:1.0),
                UIColor(red:0.56, green:0.83, blue:0.376, alpha:1.0),
                UIColor(red:0.376, green:0.765, blue:0.318, alpha:1.0),
                UIColor(red:0.192, green:0.698, blue:0.255,  alpha:1.0),
                UIColor(red:0, green:0.631, blue:0.196, alpha:1.0)]
var x = [String:String]()
let group = DispatchSemaphore(value: 0)
let everySingleFoodLoaded = DispatchSemaphore(value: 0)
var added: Set<String> = []

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
        
        let profImageRef = Storage.storage().reference(forURL: (user.photoURL!.absoluteString))

        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        profImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                currentUser.shared.profile_img = UIImage(data: data!)
            }
        }
        
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
            
            if (userInfo["ShoppingLists"] != nil) {
                currentUser.shared.shoppingListIDs = Array((userInfo["ShoppingLists"] as! [String:String]).keys)
                var j = 0
                for shoppingListID in currentUser.shared.shoppingListIDs {
                    currentUser.shared.allShoppingLists[shoppingListID] = ShoppingList()
                    currentUser.shared.allShoppingLists[shoppingListID]?.name = Array((userInfo["ShoppingLists"] as! [String:String]).values)[j]
                    j+=1
                }
            }
            
            self.observeAllList(at: currentUser.shared.allFoodListID!)
        })

    }
    
    func observeAllList(at: String) {
        let ref: DatabaseReference = Database.database().reference().child("AllFoodLists/\(at)")
        
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
                    continue
                }
                
                currentUser.shared.allFood.append(newFoodItem)
                currentUser.shared.allFood.sort() {
                    $0.timestamp < $1.timestamp
                }
            }
        
            group.signal()
            self.childAddedSema.signal()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        //Database.database().reference().removeAllObservers()
        //Database.database().reference().child("AllFoodLists/\(currentUser.shared.allFoodListID!)").removeAllObservers()
        //currentUser.shared.userRef!.removeAllObservers()
    }
    
}
