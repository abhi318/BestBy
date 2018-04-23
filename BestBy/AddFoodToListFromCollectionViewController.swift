//
//  AddFoodToListFromCollectionViewController.swift
//  BestBy
//
//  Created by Erin Jensby on 3/31/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFoodToListFromCollectionViewController: UIViewController {

    @IBOutlet weak var food_img: UIImageView!
    @IBOutlet weak var food_name: UILabel!
    @IBOutlet weak var food_desc: UILabel!
    
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var amountPicker: UIPickerView!
    
    var selected_food:String!
    var selected_food_ID: String!

    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        amountPicker.delegate = self
        amountPicker.dataSource = self
        listPicker.delegate = self
        listPicker.dataSource = self
        
        food_name.text = selected_food
        if FoodData.food_data[selected_food] == nil {
            food_img.image = UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal)
            food_desc.text = " "
        } else {
            food_img.image = FoodData.food_data[selected_food]!.2
            food_desc.text = FoodData.food_data[selected_food]!.1
        }
        
        amountPicker.selectRow(1, inComponent: 0, animated: true)

        // Do any additional setup after loading the view.
    }

    @IBAction func addToListClicked(_ sender: Any) {
        let amount = amountPicker.selectedRow(inComponent: 0)
        let list_idx = listPicker.selectedRow(inComponent: 0)
        let currentListID = currentUser.shared.shoppingListIDs[list_idx]
        
        for _ in 0..<amount {
            let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
            ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(selected_food)
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

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

extension AddFoodToListFromCollectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == listPicker {
            return currentUser.shared.allShoppingLists.count
        } else {
            return 100
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        var titleData = "\(row)"
        if pickerView == listPicker {
            let keyAtIndex = currentUser.shared.shoppingListIDs[row]
            let currentListName = currentUser.shared.allShoppingLists[keyAtIndex]?.name
            titleData = currentListName!
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!

    }
    
    
}
