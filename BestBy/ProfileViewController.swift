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
        currentUser.shared.clear()
        let logOutAlert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loadingScreen") as? LoadingScreen
            self.present(vc!, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        logOutAlert.addAction(OKAction)
        logOutAlert.addAction(cancelAction)
        self.present(logOutAlert, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
