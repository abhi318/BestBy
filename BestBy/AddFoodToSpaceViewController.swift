//
//  FoodDetailsViewController.swift
//  BestBy
//
//  Created by Erin Jensby on 3/27/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFoodToSpaceViewController: UIViewController {

    
    @IBOutlet weak var food_img: UIImageView!
    @IBOutlet weak var food_name_label: UILabel!
    @IBOutlet weak var food_desc_label: UILabel!
    
    @IBOutlet weak var space_picker: UIPickerView!
    @IBOutlet weak var days_picker: UIPickerView!
    
    var selected_food:String!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        space_picker.delegate = self
        space_picker.dataSource = self
        days_picker.delegate = self
        days_picker.dataSource = self
        
        food_name_label.text = selected_food
        food_img.image = FoodData.food_data[selected_food]!.2
        food_desc_label.text = FoodData.food_data[selected_food]?.1
        let time_to_expire = FoodData.food_data[selected_food]?.0
        days_picker.selectRow(time_to_expire!, inComponent: 0, animated: true)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addToSpaceClicked(_ sender: UIButton) {
        let daysToExpire = days_picker.selectedRow(inComponent: 0)
        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
        let doe = Int(timeInterval!)

        var currentListID = currentUser.shared.allFoodListID
        
        let space_idx = space_picker.selectedRow(inComponent: 0)
        if space_idx != 0 {
            currentListID = currentUser.shared.otherFoodListIDs[space_idx - 1]
        }
        
        let currentListName = currentUser.shared.allSpaces[currentListID!]?.name

        let post = ["name" : selected_food,
                    "timestamp" : doe,
                    "spaceID": currentListID as Any,
                    "spaceName" : currentListName as Any] as [String : Any]
        
        ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        self.navigationController?.popToRootViewController(animated: true)
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

extension AddFoodToSpaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == space_picker {
            return currentUser.shared.allSpaces.count
        } else {
            return 90
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        var titleData = "\(row)"
        if pickerView == space_picker {
            var keyAtIndex:String?
            if (row == 0){
                keyAtIndex = currentUser.shared.allFoodListID
            }
            else {
                keyAtIndex = currentUser.shared.otherFoodListIDs[row - 1]
            }
            let currentListName = currentUser.shared.allSpaces[keyAtIndex!]?.name
            titleData = currentListName!
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
}
