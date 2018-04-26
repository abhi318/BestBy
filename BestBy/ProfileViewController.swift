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
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    @IBAction func notificationPreferencesClicked(_ sender: Any) {
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType =  UIImagePickerControllerSourceType.photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
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
        username.text = "\(Auth.auth().currentUser?.email! ?? "no email")"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        
        userimage.addGestureRecognizer(tapGesture)
        userimage.isUserInteractionEnabled = true
        userimage.clipsToBounds = true
        userimage.layer.cornerRadius = 75
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentUser.shared.profile_img != nil {
            userimage.image = currentUser.shared.profile_img
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var image_data = info[UIImagePickerControllerOriginalImage] as? UIImage
        image_data = image_data?.resizeImage(targetSize: CGSize(width: 512, height: 512))
        
        currentUser.shared.profile_img = image_data!
        
        let storageRef = Storage.storage().reference()
        let profImageRef = storageRef.child("profImages/\(currentUser.shared.ID!).png")
        
        let data = UIImagePNGRepresentation(image_data!)!

        // Upload the file to firebase
    
        profImageRef.delete(completion: nil)
        let _ = profImageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                
            changeRequest.photoURL = metadata.downloadURL()
                changeRequest.commitChanges { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("photo updated")
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
