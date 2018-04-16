//
//  ShoppingListCellTableViewCell.swift
//  BestBy
//
//  Created by Erin Jensby on 2/28/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ShoppingListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var newListTextField: UITextField!
    @IBOutlet var sharedWithCollectionView: UICollectionView!
    
    @IBOutlet var shareWithTextField: UITextField!
    var listID:String!
    
    @IBOutlet var shareListButton: UIButton!
    @IBAction func shareListClicked(_ sender: Any) {
        shareWithTextField.delegate = self
        shareWithTextField.placeholder = "Enter a User's Email"
        shareWithTextField.isHidden = false
        shareWithTextField.becomeFirstResponder()
        listNameLabel.isHidden = true
        sharedWithCollectionView.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedWithCollectionView.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
        newListTextField.isHidden = true

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        sharedWithCollectionView.delegate = dataSourceDelegate
        sharedWithCollectionView.dataSource = dataSourceDelegate
        sharedWithCollectionView.tag = row
        sharedWithCollectionView.reloadData()
    }

}

extension ShoppingListCellTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if shareWithTextField.text != nil && shareWithTextField.text != "" {
            let ref = Database.database().reference()
            let encodedUserEmail = (shareWithTextField.text!).replacingOccurrences(of: ".", with: ",")
            ref.child("Users/\(encodedUserEmail)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                if snapshot.exists() {
                    let uid = snapshot.value as! String
                    ref.child("Users/\(uid)/ShoppingLists/\(self.listID!)").setValue(self.listNameLabel.text!)
                    ref.child("AllShoppingLists/\(self.listID!)/sharedWith/\(uid)").setValue(true)
                    
                    self.shareWithTextField.resignFirstResponder()
                    self.shareWithTextField.isHidden = true
                    self.listNameLabel.isHidden = false
                    self.sharedWithCollectionView.isHidden = false
                    DispatchQueue.main.async {
                        self.sharedWithCollectionView.reloadData()
                    }
                } else {
                    self.shareWithTextField.text = ""
                    self.shareWithTextField.attributedPlaceholder = NSAttributedString(string: "No user with that email",
                                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.red.withAlphaComponent(0.4)])
                }
            }, withCancel: {(err) in
                
                print(err)})
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.shareWithTextField.resignFirstResponder()
        self.shareWithTextField.isHidden = true
        self.listNameLabel.isHidden = false
        self.sharedWithCollectionView.isHidden = false
        return true
    }
}
