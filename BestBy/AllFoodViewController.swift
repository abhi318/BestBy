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

var gradient = [UIColor(red:0.50, green:0.79, blue:0.37, alpha:1.0),
                UIColor(red:0.65, green:0.82, blue:0.43, alpha:1.0),
                UIColor(red:0.74, green:0.73, blue:0.39, alpha:1.0),
                UIColor(red:0.79, green:0.60, blue:0.40, alpha:1.0),
                UIColor(red:0.77, green:0.37, blue:0.35, alpha:1.0)]

class AllFoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    private var data: [FoodItem] = []
    
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var currentListID: String! = currentUser.shared.allFoodListID!
    var currentListName: String! = "All"
    
    var itemSelected = -1;

    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
        
        observeFoodList(at: currentListID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = currentListName
        
        DispatchQueue.main.async{
            self.allFoodTableView.reloadData()
        }
    }
    
    func observeFoodList(at: String) {
        let usersDefaultFoodList = ref.child("AllFoodLists/\(at)")
    
        usersDefaultFoodList.observe(.childAdded, with: { (snapshot) in
            let foodList = snapshot.value as? [String:Any] ?? [:]
            
            let foodItem = FoodItem(id: snapshot.key, n: foodList["name"] as! String, t: foodList["timestamp"] as! Int)
            currentUser.shared.allSpaces[at]!.contents.append(foodItem)
            
            currentUser.shared.allSpaces[at]!.contents.sort() {
                $0.timestamp < $1.timestamp
            }

            self.allFoodTableView.reloadData()
        })
        
        usersDefaultFoodList.observe(.childRemoved, with: { (snapshot) in
            currentUser.shared.allSpaces.removeValue(forKey: snapshot.key)
            
            currentUser.shared.allSpaces[at]!.contents.sort() {
                $0.timestamp < $1.timestamp
            }
            
            self.allFoodTableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.shared.allSpaces[currentListID]!.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

        let foodItem = currentUser.shared.allSpaces[currentListID]!.contents[indexPath.row]
        
        print(FoodData.food_data.count)
        let daysLeft = (foodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        
        var ratio = (CGFloat(daysLeft)/40.0)
        //ratio = CGFloat(daysLeft)
        if ratio > 1 {
            ratio = 1
        }
        //print("ratio \(ratio)\tiratio \(i_ratio)\tname \(foodItem.name)")
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.bg_color.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.7)
        cell.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.1)
        //print("bg yoyoyo \(cell.bg_color.backgroundColor)")
        //cell.foodDetails.backgroundColor = cell.bg_color.backgroundColor
        cell.foodDetails.text = FoodData.food_data[foodItem.name]?.1
        cell.daysToExpire?.text = "\(daysLeft+1) days left"
        cell.foodImage.image = FoodData.food_data[foodItem.name]!.2
        cell.foodName?.text = foodItem.name



        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (itemSelected >= 0) {
            itemSelected = -1
        }
        else {
            itemSelected = indexPath.row
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (itemSelected == indexPath.row) {
            return 250
        }
        return 110
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if (segue.identifier == "foodDetail") {
//            let vc = segue.destination as! FoodDescController
//            let cell = sender as! FoodCell
//            allFoodTableView.deselectRow(at: allFoodTableView.indexPath(for: cell)!, animated: true)
//            print(cell.foodName.text!)
//            vc.passedValues = [cell.foodName.text!, cell.daysToExpire.text!, (FoodData.food_data[cell.foodName.text!]?.1)!]
//        }
//    }
}

class FoodCell: UITableViewCell {
    
    @IBOutlet weak var bg_color: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var daysToExpire: UILabel!
    @IBOutlet weak var foodDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


    

