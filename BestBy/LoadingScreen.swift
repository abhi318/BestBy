//
//  LoadingScreen.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/4/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase

class LoadingScreen: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        //try! Auth.auth().signOut()
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                currentUser.shared.ID = Auth.auth().currentUser?.uid
                currentUser.shared.userRef = Database.database().reference().child("Users/\((Auth.auth().currentUser?.uid)!)")
                
                let userFoodRef = currentUser.shared.userRef?.child("UserFoodListIDs")
                
                userFoodRef?.observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let allFoodListIDs = snapshot.value as! NSArray
                    
                    for i in 0...(allFoodListIDs.count-1){
                        currentUser.shared.allFood.append(allFoodListIDs[i] as! String)
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
    
    override func viewDidAppear(_ animated: Bool) {
        if(currentUser.shared.ID != nil) {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
