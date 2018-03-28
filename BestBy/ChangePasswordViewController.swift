//
//  ChangePasswordViewController.swift
//  BestBy
//
//  Created by Erin Jensby on 3/27/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBAction func changePassClicked(_ sender: Any) {
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let user = Auth.auth().currentUser
        let email = user?.email!
        let credential = EmailAuthProvider.credential(withEmail: email!, password: oldPassField.text!)
        
        user?.reauthenticate(with: credential, completion: { (error) in
            if error != nil {
                let incorrectPassword = UIAlertController(title: "", message: "Incorrect Password", preferredStyle: UIAlertControllerStyle.alert)
                incorrectPassword.addAction(OKAction)
                self.present(incorrectPassword, animated: true, completion: nil)
            }
            else {
                //change to new password
                if self.newPassField.text! != self.confirmPassField.text! {
                    let message = "New passwords do not match."
                    let incorrectPasswordAlert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    incorrectPasswordAlert.addAction(OKAction)
                    self.present(incorrectPasswordAlert, animated: true, completion: nil)
                    return
                }
                user?.updatePassword(to: self.newPassField.text!) {
                    (error) in
                    if error != nil {
                        let errorOccurred = UIAlertController(title: "", message: "Unable to change password.", preferredStyle: UIAlertControllerStyle.alert)
                        errorOccurred.addAction(OKAction)
                        self.present(errorOccurred, animated: true, completion: nil)
                    }
                    else {
                        let changeSuccessful = UIAlertController(title: "", message: "Change Successful", preferredStyle: UIAlertControllerStyle.alert)
                        let OKandDismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            (action: UIAlertAction) in
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        changeSuccessful.addAction(OKandDismissAction)
                        self.present(changeSuccessful, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
