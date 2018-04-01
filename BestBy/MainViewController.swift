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
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.tabBar.items?[0].image = UIImage(named: "fridge")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[0].selectedImage = UIImage(named: "fridgeSelected")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].image = UIImage(named: "items")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].selectedImage = UIImage(named: "itemsSelected")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].image = UIImage(named: "list")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].selectedImage = UIImage(named: "listSelected")?.withRenderingMode(.alwaysOriginal)
//        self.tabBar.items?[3].image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
//        self.tabBar.items?[3].selectedImage = UIImage(named: "profileSelected")?.withRenderingMode(.alwaysOriginal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
