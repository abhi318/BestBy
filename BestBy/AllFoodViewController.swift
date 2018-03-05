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
    var currentListID: String!
    var currentListName: String!
    
    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.title = currentListName
        
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
        
        observeFoodList(at: currentListID)
    }
    
    func observeFoodList(at: String) {
        currentListID = at
        let usersDefaultFoodList = ref.child("AllFoodLists/\(currentListID!)")
    
        usersDefaultFoodList.observe(.childAdded, with: { (snapshot) in
            if(snapshot.key != "name" && snapshot.key != "sharedWith") {
                let foodList = snapshot.value as? [String:Any] ?? [:]
                
                let foodItem = FoodItem(id: snapshot.key, n: foodList["name"] as! String, t: foodList["timestamp"] as! Int)
                self.data.append(foodItem)
                self.data.sort() {
                    $0.timestamp < $1.timestamp
                }
                
                self.allFoodTableView.reloadData()
            }
        })
        
        usersDefaultFoodList.observe(.childRemoved, with: { (snapshot) in
            let foodList = snapshot.value as? [String:Any] ?? [:]
            
            let foodItem = FoodItem(id: snapshot.key, n: foodList["name"] as! String, t: foodList["timestamp"] as! Int)
            if let index = self.data.index(where: {$0 == foodItem}) {
                self.data.remove(at: index)
            }
            self.data.sort() {
                $0.timestamp < $1.timestamp
            }
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
        cell.foodName?.text = foodItem.name
        
        let daysLeft = (foodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        cell.daysToExpire?.text = "\(daysLeft+1) days"

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


    

