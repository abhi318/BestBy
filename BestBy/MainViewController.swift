//
//  MainViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/13/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import Firebase

class MainViewController: UITabBarController  {
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentUser: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.currentUser = user
                print("users id" + (user?.email)!)
            }
            else{
                print("presenting boiii")
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
