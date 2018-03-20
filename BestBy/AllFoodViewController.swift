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

    private var data: [FoodItem] = []
    
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var currentListID: String! = currentUser.shared.allFoodListID!

    var currentListName: String!

    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.title = currentListName
        
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if currentUser.shared.foodBySpaces[currentListID] == nil {
            currentUser.shared.foodBySpaces[currentListID] = [FoodItem]()
            observeFoodList(at: currentListID)
        }
        
        self.allFoodTableView.reloadData()
    }
    
    func observeFoodList(at: String) {
        let usersDefaultFoodList = ref.child("AllFoodLists/\(at)")
    
        usersDefaultFoodList.observe(.childAdded, with: { (snapshot) in
            let foodList = snapshot.value as? [String:Any] ?? [:]
            
            let foodItem = FoodItem(id: snapshot.key, n: foodList["name"] as! String, t: foodList["timestamp"] as! Int)
            currentUser.shared.foodBySpaces[at]!.append(foodItem)
            
            currentUser.shared.foodBySpaces[at]!.sort() {
                $0.timestamp < $1.timestamp
            }

            self.allFoodTableView.reloadData()
        })
        
        usersDefaultFoodList.observe(.childRemoved, with: { (snapshot) in
            currentUser.shared.foodBySpaces.removeValue(forKey: snapshot.key)
            
            currentUser.shared.foodBySpaces[at]!.sort() {
                $0.timestamp < $1.timestamp
            }
            
            self.allFoodTableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.shared.foodBySpaces[currentListID]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

        let foodItem = currentUser.shared.foodBySpaces[currentListID]![indexPath.row]
        
        cell.foodName?.text = foodItem.name
        
        let daysLeft = (foodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        cell.daysToExpire?.text = "\(daysLeft+1) days left"

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "foodDetail") {
            let vc = segue.destination as! FoodDescController
            let cell = sender as! FoodCell
            allFoodTableView.deselectRow(at: allFoodTableView.indexPath(for: cell)!, animated: true)
            vc.passedValues = [cell.foodName.text!, cell.daysToExpire.text!, (FoodData.food_data[cell.foodName.text!]?.1)!]
        }
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


    

