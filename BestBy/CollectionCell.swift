//
//  CollectionCell.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/5/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet var addToSpace: UIButton!
    @IBOutlet var addToShoppingList: UIButton!
    @IBAction func spaceButtonClicked(_ sender: Any) {
        let foodAdded: String = foodName.text!
        
        var daysToExpire = FoodData.food_data[foodAdded]!.0
        
        let ref = Database.database().reference()
        
        if daysToExpire <= 0 {
            daysToExpire = 10000
        }
        
        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
        let doe = Int(timeInterval!)
        
        //post name of food, and seconds from reference date (jan 1, 2001) that it will expire
        let post = ["name" : foodAdded,
                    "timestamp" : doe] as [String : Any]
        
        ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        
        if daysToExpire < 1000 {
            getNotificationForDay(on: dateOfExpiration!, foodName: foodAdded)
        }
        self.addToShoppingList.isHidden = true
        self.addToSpace.isHidden = true
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
    
    var timeRemaining: UILabel =  {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getNotificationForDay(on: Date, foodName: String) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if let requestTriggerDate = (request.trigger as! UNCalendarNotificationTrigger).nextTriggerDate() {
                    let order = calendar.compare(requestTriggerDate, to: on, toGranularity: .day)
                    if order.rawValue == 0 {
                        self.addRequest(calendar: calendar, request: request, center: center, foodName: foodName, date: on)
                        return
                    }
                }
                else {
                    center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                }
            }
            self.addRequest(calendar: calendar, request: nil, center: center, foodName: foodName, date: on)
            return
        })
    }
}
