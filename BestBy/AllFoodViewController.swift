//
//  AllFoodViewController.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 2/16/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import UIKit

class AllFoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    private var data: [(String, Int)] = []
    
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var currentListIdx: Int = 0
    var currentListID: String!
    
    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        currentListID = currentUser.shared.allFood[0]
        let usersDefaultFoodList: DatabaseReference = ref.child("AllFoodLists").child(currentListID)
        
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
        
        usersDefaultFoodList.observe(.childAdded, with: { (snapshot) in
            let foodList = snapshot.value as? [String:Any] ?? [:]
            
            let foodItem = (foodList["name"] as! String, foodList["timestamp"] as! Int)
            self.data.append(foodItem)
            
            self.allFoodTableView.reloadData()
        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

        let foodItem = self.data[indexPath.row]
        cell.foodName?.text = foodItem.0
        
        let daysLeft = (foodItem.1 - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        cell.daysToExpire?.text = "\(daysLeft) days"

        return cell
    }
}

class FoodCell: UITableViewCell {
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var daysToExpire: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


//    @IBAction func addItem(_ sender: Any) {
//        let alert = UIAlertController(title: "Grocery Item",
//                                      message: "Add an Item",
//                                      preferredStyle: .alert)
//
//        let saveAction = UIAlertAction(title: "Save",
//                                       style: .default) { _ in
//                                        guard let textField = alert.textFields?.first,
//                                            let text = textField.text else { return }
//
//                                        // 2
//                                        let foodItem = Food(name: textField.text!)
//                                        // 3
//                                        let foodItemRef = self.ref.child(text.lowercased())
//
//                                        // 4
//                                        foodItemRef.setValue(foodItem.toAnyObject())
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .default)
//
//        alert.addTextField()
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
