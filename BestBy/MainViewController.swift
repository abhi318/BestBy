//
//  MainViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/13/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class MainViewController: UITabBarController  {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user != nil {
                currentUser.shared.ID = Auth.auth().currentUser?.uid
                currentUser.shared.userRef = Database.database().reference().child("Users/\((Auth.auth().currentUser?.uid)!)")
            }
            else {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signinview") as? SignInViewController
                self.present(vc!, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
