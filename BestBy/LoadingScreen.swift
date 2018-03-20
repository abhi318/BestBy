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

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Database.database().reference().child("EverySingleFood").observeSingleEvent(of: .value, with: { (snapshot) in
            let allFoodDict = snapshot.value as! [String:[String:Any]]
            for(key, value) in allFoodDict {
                FoodData.food_data[key] = (value["doe"] as! Int, value["desc"] as! String)
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
        currentUser.shared.userRef = ref.child("Users/\((user.uid))")
        
        loadAllUsersFood(userAllFoodRef: currentUser.shared.userRef!.child("AllUsersFood"))
        //loadAllUsersSpacesIDs(userFoodRef: currentUser.shared.userRef!.child("UserFoodListIDs"))
        
    }
    
    func loadAllUsersFood(userAllFoodRef: DatabaseReference) {
        userAllFoodRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            print(snapshot)
            currentUser.shared.allFoodListID = snapshot.value as! String!
            currentUser.shared.allSpaces.append((snapshot.value as! String, "All"))

            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as? MainViewController
            self.present(vc!, animated: true, completion: nil)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
