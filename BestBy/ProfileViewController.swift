//
//  ProfileViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/16/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBAction func signoutButton(_ sender:Any) {
        try! Auth.auth().signOut()
        
        if let tabbarController = self.tabBarController {
            tabbarController.selectedIndex = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
