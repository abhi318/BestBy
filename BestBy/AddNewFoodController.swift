//
//  AddNewFoodController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 4/12/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddNewFoodController: UIViewController, UITextViewDelegate {
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addNewFood(_ sender: Any) {
        if (name.text! == "") {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let userRef: DatabaseReference = currentUser.shared.userRef!
        var doe = daysPicker.selectedRow(inComponent: 0)
        if doe == 0 {
            doe = -2
        }
        
        userRef.child("ExtraFoods/\(name.text!)").setValue(["doe": doe,
                                                      "desc": desc.text])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var daysPicker: UIPickerView!
    @IBOutlet var desc: UITextView!
    @IBOutlet var name: UITextField!
    @IBOutlet var img: UIImageView!
    
    var foodName: String!
    var im: UIImage!
    var foodDesc: String!
    var doe: Int!
    @IBOutlet var addButton: UIButton!
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "New Food Description")
        {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == "" && foodName == nil
        {
            textView.text = "New Food Description"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysPicker.delegate = self
        daysPicker.dataSource = self
        desc.delegate = self
        desc.textColor = .black

        if foodName != nil {
            name.text = foodName
            name.isUserInteractionEnabled = false
            img.image = im
            
            addButton.setTitle("DONE", for: .normal)
            desc.text = foodDesc
            if foodDesc == "" {
                desc.text = "New Food Description"
                desc.textColor = .lightGray

            }
            if doe < 0 {
                doe = 0
            }
            daysPicker.selectRow(doe, inComponent: 0, animated: true)
        } else {
            desc.text = "New Food Description"
            desc.textColor = .lightGray

            addButton.setTitle("ADD NEW FOOD", for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension AddNewFoodController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        
        var titleData = "\(row)"
        if row == 0{
            titleData = infinity
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
    }
}

