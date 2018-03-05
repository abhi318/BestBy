//
//  MainViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/13/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class MainViewController: UITabBarController  {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?[0].image = UIImage(named: "fridge")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[0].selectedImage = UIImage(named: "fridgeSelected")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].image = UIImage(named: "list")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].selectedImage = UIImage(named: "listSelected")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].selectedImage = UIImage(named: "profileSelected")?.withRenderingMode(.alwaysOriginal)

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
    }
}
