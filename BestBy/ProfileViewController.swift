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
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    
    @IBOutlet weak var username: UILabel!
    @IBAction func contactUsClicked(_ sender: Any) {
        
        let contactAlert = UIAlertController(title: "", message: "Please sumbit your message below and we will email you with our response.", preferredStyle: UIAlertControllerStyle.alert)
        contactAlert.addTextField { (textField) in
            textField.placeholder = "Write your message here."
        }
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            let messageField = contactAlert.textFields![0] as UITextField
            self.ref.child("Feedback/\(currentUser.shared.ID!)").childByAutoId().setValue(messageField.text)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        contactAlert.addAction(OKAction)
        contactAlert.addAction(cancelAction)
        self.present(contactAlert, animated: true, completion: nil)

    }
    
    @IBAction func followUsClicked(_ sender: Any) {
        let screenName =  "BestByApp"
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        if UIApplication.shared.canOpenURL(appURL as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL as URL)
            }
        } else {
            //redirect to safari because the user doesn't have Instagram
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL as URL)
            }
        }
    }
    
    @IBAction func signoutButton(_ sender:Any) {
        let logOutAlert = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (action: UIAlertAction) in
            
            try! Auth.auth().signOut()
            currentUser.shared.clear()
            FoodData.food_data.removeAll()
            
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
        
        ref = Database.database().reference()
        username.text = Auth.auth().currentUser?.email
        
//        b1.backgroundColor = gradient[4].withAlphaComponent(0.7)
//        b2.backgroundColor = gradient[3].withAlphaComponent(0.7)
//        b3.backgroundColor = gradient[2].withAlphaComponent(0.7)
//        b4.backgroundColor = gradient[1].withAlphaComponent(0.7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
