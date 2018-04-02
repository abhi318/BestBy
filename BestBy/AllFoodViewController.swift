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
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        allFoodTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = currentListName

        DispatchQueue.main.async{
            self.allFoodTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(allFoodTableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentUser.shared.allSpaces[currentListID] != nil {
            return currentUser.shared.allSpaces[currentListID]!.contents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

        let foodItem = currentUser.shared.allSpaces[currentListID]!.contents[indexPath.row]
        
        let daysLeft = (foodItem.timestamp - Int(Date().timeIntervalSinceReferenceDate)) / 86400
        
        var ratio = (CGFloat(daysLeft)/14.0)

        if ratio > 1 {
            ratio = 1
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.bg_color.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.4)
        cell.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.05)

        cell.daysToExpire?.text = ( daysLeft > 1000 ) ? "\(infinity) days left" : "\(daysLeft+1) days left"
        
        if FoodData.food_data[foodItem.name] != nil {
            cell.foodDetails.text = FoodData.food_data[foodItem.name]!.1
            cell.foodImage.image = FoodData.food_data[foodItem.name]!.2
        } else {
            FoodData.food_data[foodItem.name] = (-2, "", UIImage(named: "groceries")!.withRenderingMode(.alwaysOriginal))
            cell.foodDetails.text = FoodData.food_data[foodItem.name]!.1
            cell.foodImage.image = FoodData.food_data[foodItem.name]!.2
        }
        
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
        let foodItem = currentUser.shared.allSpaces[currentListID]!.contents[indexPath.row]
        if (itemSelected == indexPath.row && FoodData.food_data[foodItem.name]?.1.count != nil) {
            return CGFloat(70 + (FoodData.food_data[foodItem.name]?.1.count)! / 2);
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let id = currentUser.shared.allSpaces[self.currentListID]!.contents[indexPath.row]

            currentUser.shared.allSpaces[self.currentListID]!.contents.remove(at: indexPath.row)
            Database.database().reference().child("AllFoodLists/\(self.currentListID!)/\(id.ID)").removeValue()
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadEmptyStateForTableView(self.allFoodTableView)
        }
        
        return [delete]
    }
}

extension AllFoodViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    var emptyStateImage: UIImage? {
        return UIImage(named: "items")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22)]
        if currentListName == "All" {
            return NSAttributedString(string: "No Food Yet", attributes: attrs)
        }
        else {
            return NSAttributedString(string: "No Food in \(currentListName!) Yet", attributes: attrs)
        }
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        return NSAttributedString(string: "Add Some", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 100, height: 40)
    }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        
        emptyView.button.layer.cornerRadius = 5
        emptyView.button.layer.borderWidth = 1
        emptyView.button.layer.borderColor = gradient[3].cgColor
        emptyView.button.layer.backgroundColor = gradient[2].cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        performSegue(withIdentifier: "search" , sender: self)
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


    

