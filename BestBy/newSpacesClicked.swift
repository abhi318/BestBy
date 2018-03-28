//
//  newSpacesClicked.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/22/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

protocol reloadProtocol : NSObjectProtocol {
    func reloadData()
}

class newSpaceClicked : UIViewController {
    
    @IBOutlet weak var textField: UITextField?
    @IBOutlet weak var label: UILabel?
    
    var delegate: reloadProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            label?.isHidden = true
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            label?.isHidden = false
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension newSpaceClicked: UITextFieldDelegate {
    func textFieldShouldReturn(_ textF: UITextField) -> Bool {
        if textF == textField {
            let listRef = Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces").childByAutoId()
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/Spaces/\(listRef.key)").setValue(textField?.text)
            
            currentUser.shared.otherFoodListIDs.append(listRef.key)
            
            currentUser.shared.allSpaces[listRef.key] = FoodList()
            currentUser.shared.allSpaces[listRef.key]!.name = textField?.text
            
            self.delegate!.reloadData()

            textField?.text = ""
            textField?.isEnabled = false
            textField?.resignFirstResponder()
            
            //self.label?.isHidden = !(self.label.isHidden)


            return false
        }
        return true
    }
}
