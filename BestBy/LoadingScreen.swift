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

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var done = false;
    var i = 0;
    let group = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadEverySingleFood()
    }
    
    func loadEverySingleFood() {
        i = 0
        
        Database.database().reference().child("EverySingleFood").observeSingleEvent(of: .value, with: { (snapshot) in
            let newFood = snapshot.value as! [String:[String:Any]]
            for (key, value) in newFood {
                FoodData.food_data[key] = (value["doe"] as! Int, value["desc"] as! String, UIImage(named: value["img_name"] as! String))
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //try! Auth.auth().signOut()
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                self.fillCurrentUserSingleton(user: user!)
                
                print()
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
            
            userRef.removeAllObservers()
            self.observeAllList(at: currentUser.shared.allFoodListID!)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as? MainViewController
            self.present(vc!, animated: true, completion: nil)
        })
    }
    func observeAllList(at: String) {
        let ref: DatabaseReference = Database.database().reference().child("AllFoodLists/\(at)")
        ref.observe(.childAdded, with: {snapshot in
            let foodInfo = snapshot.value as! [String:Any]
            let newFoodItem = FoodItem(id: snapshot.key,
                                       n: foodInfo["name"] as! String,
                                       t: foodInfo["timestamp"] as! Int)
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
