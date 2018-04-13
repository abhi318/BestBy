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
import UserNotifications


class AddFoodToSpaceViewController: UIViewController {

    
    @IBOutlet weak var food_img: UIImageView!
    @IBOutlet weak var food_name_label: UILabel!
    @IBOutlet weak var food_desc_label: UILabel!
    
    @IBOutlet weak var days_picker: UIPickerView!
    
    @IBOutlet weak var daysLabel: UILabel!
    
    var selected_food:String!
    var selected_food_ID: String!
    var shoppingListID: String!
    var idx: IndexPath!
    var desc: String!
    
    var from: String!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        days_picker.delegate = self
        days_picker.dataSource = self
        
        daysLabel.isHidden = false
        days_picker.isHidden = false
        
        if from == "ShoppingListsViewController" {
            daysLabel.isHidden = true
            days_picker.isHidden = true
        }
        
        food_name_label.text = selected_food
        
        var time_to_expire = 0
        if FoodData.food_data[selected_food] == nil {
            food_img.image = UIImage(named: "groceries")
            food_desc_label.text = desc
            time_to_expire = -2

        }
        else {
            food_img.image = FoodData.food_data[selected_food]!.2
            food_desc_label.text = FoodData.food_data[selected_food]!.1
            time_to_expire = FoodData.food_data[selected_food]!.0
        }
        
        if time_to_expire < 0 {
            time_to_expire = 0
        }

        days_picker.selectRow(time_to_expire, inComponent: 0, animated: true)

    }
    
    @IBAction func addToSpaceClicked(_ sender: UIButton) {
        var daysToExpire = days_picker.selectedRow(inComponent: 0)

        if (from == "ShoppingListsViewController") {
            for i in currentUser.shared.allShoppingLists[selected_food_ID]!.contents {
                if FoodData.food_data[i.name] != nil{
                    daysToExpire = FoodData.food_data[i.name]!.0
                }
                
                else {
                    daysToExpire = ((daysToExpire == 0) ? -2 : daysToExpire)
                    FoodData.food_data[i.name] = (daysToExpire, "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
                    
                    ref.child("Users/\(currentUser.shared.ID!)/ExtraFoods/\(i.name)").setValue(daysToExpire)
                }
                
                if daysToExpire <= 0 {
                    daysToExpire = 10000
                }
                
                let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
                let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
                let doe = Int(timeInterval!)
                                
                let post = ["name" : i.name,
                            "timestamp" : doe] as [String : Any]
                
                ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
                if daysToExpire < 1000 {
                    getNotificationForDay(on: dateOfExpiration!, foodName: selected_food)
                }
            }
            days_picker.isHidden = false
            
            currentUser.shared.shoppingListIDs.remove(at: idx.row)
            currentUser.shared.allShoppingLists.removeValue(forKey: selected_food_ID)
            
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(selected_food_ID!)").removeValue()
        }
        else {
            let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
            let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
            let doe = Int(timeInterval!)
        
            if FoodData.food_data[selected_food] == nil {
                daysToExpire = ((daysToExpire == 0) ? -2 : daysToExpire)
                FoodData.food_data[selected_food] = (daysToExpire, "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
                
                ref.child("Users/\(currentUser.shared.ID!)/ExtraFoods/\(selected_food)").setValue(daysToExpire)
            }
            
            if daysToExpire < 0 {
                daysToExpire = 10000
            }
        
            let post = ["name" : selected_food,
                        "timestamp" : doe] as [String : Any]
        
            ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        
            if (from == "AddToShopListViewController") {
                currentUser.shared.allShoppingLists[shoppingListID]!.contents.remove(at: idx.row)
                ref.child("AllShoppingLists/\(shoppingListID!)/\(selected_food_ID!)").removeValue()
            }

            getNotificationForDay(on: dateOfExpiration!, foodName: selected_food)

        }
        
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func getNotificationForDay(on: Date, foodName: String) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                
                let requestTriggerDate = (request.trigger as! UNCalendarNotificationTrigger).nextTriggerDate()
                
                let order = calendar.compare(requestTriggerDate!, to: on, toGranularity: .day)
                if order.rawValue == 0 {
                    self.addRequest(calendar: calendar, request: request, center: center, foodName: foodName, date: on)
                    return
                }
            }
            self.addRequest(calendar: calendar, request: nil, center: center, foodName: foodName, date: on)
            return
        })
    }
    
    func addRequest(calendar: Calendar, request: UNNotificationRequest?, center: UNUserNotificationCenter, foodName: String, date: Date) {
        let content = UNMutableNotificationContent()
        var identifier: String?
        var trigger: UNCalendarNotificationTrigger?
        
        if request == nil {
            content.title = "What's expiring today?"
            content.body = "\(foodName)"
            
            
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day], from: date)
            identifier = "\(triggerDate.month!)/\(triggerDate.day!)/\(triggerDate.year!)"
            
            triggerDate.hour = 9
            triggerDate.minute = 0
            triggerDate.second = 0
            
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        }
        else {
            content.title = request!.content.title
            content.body = request!.content.body + ", \(foodName)"
        }
        let request = UNNotificationRequest(identifier: (request != nil) ? request!.identifier : identifier!,
                                            content: content, trigger: (request != nil) ? request!.trigger : trigger!)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddFoodToSpaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 90
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        let titleData = "\(row)"
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
        
    }
    
}
