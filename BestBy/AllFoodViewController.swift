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
import UIEmptyState

class AllFoodViewController: UIViewController  {
    
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var foodRef: DatabaseReference!
    var foodHandle: DatabaseHandle!
    var currentListID: String! = currentUser.shared.allFoodListID!
    var flag: Bool = true
    var itemSelected = -1;
    
    
    private var expiredFoods: [String]! = ["test"]

    @IBOutlet var expiredTableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            flag = true
            DispatchQueue.main.async {
                self.allFoodTableView.reloadData()
                self.reloadEmptyStateForTableView(self.allFoodTableView)
            }
            expiredTableView.isHidden = true
            allFoodTableView.isHidden = false
            self.navigationItem.title = "Pantry"
            
        case 1:
            flag = false
            DispatchQueue.main.async {
                self.expiredTableView.reloadData()
                self.reloadEmptyStateForTableView(self.expiredTableView)
            }
            expiredTableView.isHidden = false
            allFoodTableView.isHidden = true
            self.navigationItem.title = "Expired Foods"
        default:
            break
        }
    }
    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        segmentedControl.setTitle("Pantry", forSegmentAt: 0)
        segmentedControl.setTitle("Expired", forSegmentAt: 1)
        
        segmentedControl.layer.cornerRadius = 0
        segmentedControl.layer.borderColor = segmentedControl.tintColor.cgColor
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.masksToBounds = true
        
        self.navigationItem.title = "Pantry"
        
        ref = Database.database().reference()
        foodRef = ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)")
        
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
        
        expiredTableView.delegate = self
        expiredTableView.dataSource = self
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        allFoodTableView.tableFooterView = UIView(frame: CGRect.zero)
        expiredTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func observeFoodList() {
        foodHandle = foodRef.observe(.childAdded, with: { (snapshot) in
            if(!added.contains(snapshot.key)) {
                let foodInfo = snapshot.value as! [String : Any]
            
                print("info: \(foodInfo)")
            
                let newFoodItem = FoodItem(id: snapshot.key,
                                           n: foodInfo["name"] as! String,
                                           t: foodInfo["timestamp"] as! Int)
                added.insert(snapshot.key)
            
                if (newFoodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400 < 1 {
                    self.expiredFoods.append(newFoodItem.name)
                }
                    
                else {
                    currentUser.shared.allFood.append(newFoodItem)
                    currentUser.shared.allFood.sort() {
                        $0.timestamp < $1.timestamp
                    }
                    
                    DispatchQueue.main.async{
                        self.allFoodTableView.reloadData()
                        self.reloadEmptyStateForTableView(self.allFoodTableView)
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segmentedControl.selectedSegmentIndex = 0
        indexChanged(segmentedControl)
        observeFoodList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        foodRef.removeObserver(withHandle: foodHandle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(allFoodTableView)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToShopListFromExpiredList" {
            if let destinationVC = segue.destination as? AddFoodToListFromCollectionViewController {
                destinationVC.selected_food = expiredFoods[(sender as! UIButton).tag]
            }
        }
    }
    
    @objc func addToShopListSegue(button:UIButton) {
        if currentUser.shared.shoppingListIDs.count == 0 {
            self.tabBarController?.selectedIndex = 1
        } else if currentUser.shared.shoppingListIDs.count == 1 {
            let currentListID = currentUser.shared.shoppingListIDs[0]
            
            let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
            ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(expiredFoods[button.tag])
            
            expiredFoods.remove(at: button.tag)
            DispatchQueue.main.async {
                self.expiredTableView.reloadData()
                self.reloadEmptyStateForTableView(self.expiredTableView)
            }
            
        } else {
            self.performSegue(withIdentifier: "addToShopListFromExpiredList", sender: button)
        }
    }
    
}
   
extension AllFoodViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == expiredTableView {
            return expiredFoods.count
        }
        return currentUser.shared.allFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == allFoodTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

            let foodItem = currentUser.shared.allFood[indexPath.row]
            
            let daysLeft = (foodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400
            
            var ratio = (CGFloat(daysLeft)/14.0)

            if ratio > 1 {
                ratio = 1
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.bg_color.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.4)
            cell.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.05)

            cell.daysToExpire?.text = ( daysLeft > 1000 ) ? "\(infinity) days left" : "\(daysLeft+1) days left"
            
            if FoodData.food_data[foodItem.name] == nil {
                FoodData.food_data[foodItem.name] = (-2, "", UIImage(named: "groceries")!.withRenderingMode(.alwaysOriginal))
            }
            
            cell.foodDetails.text = FoodData.food_data[foodItem.name]!.1
            cell.foodImage.image = FoodData.food_data[foodItem.name]!.2
            
            cell.foodName?.text = foodItem.name

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "expiredFoodCell") as! ExpiredFoodCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.foodName?.text = expiredFoods[indexPath.row]
            cell.button.tag = indexPath.row
            
            cell.button.addTarget(self, action: #selector(addToShopListSegue), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView == allFoodTableView {
            if (itemSelected >= 0) {
                itemSelected = -1
            }
            else {
                itemSelected = indexPath.row
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == allFoodTableView {
            let foodItem = currentUser.shared.allFood[indexPath.row]
            if (itemSelected == indexPath.row && FoodData.food_data[foodItem.name]?.1.count != nil && FoodData.food_data[foodItem.name]?.1 != "") {
                return CGFloat(80 + (FoodData.food_data[foodItem.name]?.1.count)! / 2);
            }
            return 60
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == allFoodTableView {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                let id = currentUser.shared.allFood[indexPath.row]
                currentUser.shared.allFood.remove(at: indexPath.row)

                tableView.deleteRows(at: [indexPath], with: .fade)
                self.reloadEmptyStateForTableView(self.allFoodTableView)
                self.foodRef.child("\(id.ID)").removeValue()

            }
            
            return [delete]
        } else {
            return []
        }
    }
}

extension AllFoodViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    var emptyStateImage: UIImage? {
        return UIImage(named: "basket_512")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:22.0)!]
        if flag {
            return NSAttributedString(string: "No Food Yet", attributes: attrs)
        }
        return NSAttributedString(string: "No Expired Food Yet", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:16.0)!]
        if flag {
            return NSAttributedString(string: "Add Some", attributes: attrs)
        }
        return nil
    }
    
    var emptyStateButtonSize: CGSize? {
        if flag {
            return CGSize(width: 100, height: 40)
        }
        return nil
    }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        if flag {
            emptyView.button.layer.cornerRadius = 5
            emptyView.button.layer.borderWidth = 1
            emptyView.button.layer.borderColor = gradient[3].cgColor
            emptyView.button.layer.backgroundColor = gradient[2].cgColor
        }
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        if flag {
            performSegue(withIdentifier: "search" , sender: self)
        }
    }
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

class ExpiredFoodCell: UITableViewCell {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


    

