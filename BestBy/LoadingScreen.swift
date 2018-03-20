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

var realNames: [String] =
    ["apples","asparagus","avocados","bananas","blueberries","broccoli","butter","butter lettuce","butternut squash","carrots","cauliflower","celery","corn","cucumber","eggs","fingerling potatoes","grapes","green beans","green bell peppers","iceburg lettuce","kale","leaf lettuce","lemons","limes","milk","mushrooms","onions","orange bell peppers","oranges","peaches","pears","pineapples","pomegranates","red bell peppers","red potatoes","romaine lettuce","russet potatoes","sour cream","spaghetti squash","strawberries","summer squash","sweet potatoes","tomatoes","watermelon","white potatoes","winter squash","yellow bell peppers","yogurt","yukon gold potatoes","zucchini"]

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var done = false;
    var i = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEverySingleFood()
    }
    func loadEverySingleFood() {
        let storageRef = Storage.storage().reference()
        i = 0
        Database.database().reference().child("EverySingleFood").observeSingleEvent(of: .value, with: { (snapshot) in
            let newFood = snapshot.value as! [String:[String:Any]]
            for(key, value) in newFood {
                let imgRef = storageRef.child("images/\(value["img_name"]!)")
                imgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if error != nil {
                        print(error ?? "momomomo")
                    } else {
                        FoodData.food_data[key] = (value["doe"] as! Int, value["desc"] as! String, UIImage(data: data!))
                    }
                }
//
//                download.observe(.success) { snapshot in
//                    self.i += 1
//                    download.removeAllObservers()
//                }
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //try! Auth.auth().signOut()
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                self.fillCurrentUserSingleton(user: user!)
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
        print(user.uid)
        loadAllUsersFood(userAllFoodRef: currentUser.shared.userRef!.child("AllUsersFood"))
    }
    
    func loadAllUsersFood(userAllFoodRef: DatabaseReference) {
        userAllFoodRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            currentUser.shared.allFoodListID = snapshot.value as! String!
            currentUser.shared.allSpaces.append((snapshot.value as! String, "All"))
            sleep(5)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as? MainViewController
            self.present(vc!, animated: true, completion: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        Database.database().reference().removeAllObservers()
    }
    
}
