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
                currentUser.shared.ID = Auth.auth().currentUser?.uid
                currentUser.shared.userRef = Database.database().reference().child("Users/\((Auth.auth().currentUser?.uid)!)")
                
                
                Database.database().reference().child("Users/\(currentUser.shared.ID!)/DefaultFoodList").observeSingleEvent(of: .value, with: {(snapshot) in
                    currentUser.shared.currentListID = (snapshot.value as! String)
                })
                
                let userFoodRef = currentUser.shared.userRef?.child("UserFoodListIDs")
                userFoodRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let allFoodListIDs = snapshot.value as! [String: Bool]
                    
                    for (id,_) in allFoodListIDs{
                        currentUser.shared.allFood.append(id)
                    }
                    
                    
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as? MainViewController
                    self.present(vc!, animated: true, completion: nil)
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signinview") as? SignInViewController
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
