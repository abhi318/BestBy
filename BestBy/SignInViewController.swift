//
//  ViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/12/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignInViewController: UIViewController, UIGestureRecognizerDelegate  {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    
    var ref: DatabaseReference!
    
    var handle: AuthStateDidChangeListenerHandle?
    var loading: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        ref =  Database.database().reference()

        loading.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        loading.center = self.view.center
        loading.hidesWhenStopped = true
        self.view.addSubview(loading)
        confirmPassword.isHidden = true
        LoginButton.isHidden = false
        backButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        Auth.auth().removeStateDidChangeListener(handle!)

    }
    
    @IBAction func LogInTapped(_ sender: Any) {
        if let userEmail = self.email.text, let password = self.password.text {
            self.loading.startAnimating()
            Auth.auth().signIn(withEmail: userEmail, password: password) { (user, error) in
                self.loading.stopAnimating()
                if let error = error {
                    print(error.localizedDescription )
                    let userErrorAlert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let OKAction = UIAlertAction(title: "OK",
                                                     style: .default)
                    userErrorAlert.addAction(OKAction)
                    self.present(userErrorAlert, animated: true, completion: nil)

                    return
                }
                print("Login successful")
                //(self.presentingViewController as! LoadingScreen).fillCurrentUserSingleton(user: user!)
//                DispatchQueue.global(qos: .background).async {
//                    group.wait()
//                    everySingleFoodLoaded.wait()
//                    self.dismiss(animated: true, completion: nil)
//                }
            }
            self.loading.stopAnimating()
        } else {
            let userErrorAlert = UIAlertController(title: "", message: "Please enter a valid email address and confirm password.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK",
                                         style: .default)
            userErrorAlert.addAction(OKAction)
            self.present(userErrorAlert, animated: true, completion: nil)
        }

    }
    
    @IBAction func NewAccountTapped(_ sender: Any) {
        if LoginButton.isHidden == false {
            LoginButton.isHidden = true
            confirmPassword.isHidden = false;
            backButton.isHidden = false;
        } else {
            if let userEmail = self.email.text, let password = self.password.text,
                password == self.confirmPassword.text
            {
                self.loading.startAnimating()
                Auth.auth().createUser(withEmail: userEmail, password: password) { (user, error) in
                    self.loading.stopAnimating()
                    if let error = error {
                        print(error.localizedDescription)
                        let userErrorAlert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let OKAction = UIAlertAction(title: "OK",
                                                     style: .default)
                        userErrorAlert.addAction(OKAction)
                        self.present(userErrorAlert, animated: true, completion: nil)
                        
                        return
                    }
                    print("\(user!.email!) created")
                    
                    self.makeANewFoodList(uid: user!.uid)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                print("fill in a username AND password")
                let userErrorAlert = UIAlertController(title: "", message: "Please enter a valid email address and confirm password.", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK",
                                             style: .default)
                userErrorAlert.addAction(OKAction)
                self.present(userErrorAlert, animated: true, completion: nil)
            }
        }

    }
    
    func makeANewFoodList(uid: String) {
        let newFoodIDref: DatabaseReference  = self.ref.child("AllFoodLists").childByAutoId()
        let newFoodID = newFoodIDref.key
        
        self.ref?.child("Users/\(uid)/AllUsersFood").setValue(newFoodID)
        let x = self.ref.child("AllFoodLists").childByAutoId()
        let y = self.ref.child("AllFoodLists").childByAutoId()
        let z = self.ref.child("AllFoodLists").childByAutoId()
        self.ref?.child("Users/\(uid)/Spaces").setValue([x.key : "Fridge",
                                                         y.key : "Pantry",
                                                         z.key : "Essentials"])

        
    }
    
    @IBAction func BackToLogin(_ sender: Any) {
        confirmPassword.isHidden = true;
        LoginButton.isHidden = false;
        backButton.isHidden = true;
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: UIControl.self))! {
            return false
        }
        self.dismissKeyboard()
        return true
    }
}

