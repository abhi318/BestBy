//
//  CollectionCell.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/5/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import UserNotifications

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet var addToSpace: UIButton!
    @IBOutlet var addToShoppingList: UIButton!
    @IBOutlet var editFoodButton: UIButton!
    
    @IBAction func editFoodsClicked(_ sender: Any) {
    }
    @IBAction func spaceButtonClicked(_ sender: Any) {
//        let foodAdded: String = foodName.text!
//        
//        var daysToExpire = FoodData.food_data[foodAdded]!.0
//        
//        let ref = Database.database().reference()
//        
//        if daysToExpire <= 0 {
//            daysToExpire = 10000
//        }
//        
//        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
//        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
//        let doe = Int(timeInterval!)
//        
//        //post name of food, and seconds from reference date (jan 1, 2001) that it will expire
//        let post = ["name" : foodAdded,
//                    "timestamp" : doe] as [String : Any]
//        
//        ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
//        
//        if daysToExpire < 1000 {
//            getNotificationForDay(on: dateOfExpiration!, foodName: foodAdded)
//        }
//        self.addToShoppingList.isHidden = true
//        self.addToSpace.isHidden = true
    }
    
    var timeRemaining: UILabel =  {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
