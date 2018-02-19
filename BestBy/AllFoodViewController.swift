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

    private var data: [Food] = []
    var ref: DatabaseReference!
    
    @IBAction func addItem(_ sender: Any) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                        
                                        // 2
                                        let foodItem = Food(name: textField.text!)
                                        // 3
                                        let foodItemRef = self.ref.child(text.lowercased())
                                        
                                        // 4
                                        foodItemRef.setValue(foodItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var allFoodTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFoodTableView.dataSource = self
        allFoodTableView.delegate = self
        ref = Database.database().reference()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell

        let text = data[indexPath.row].foodName
        
        cell.foodName?.text = text
        cell.daysToExpire?.text = "u got 5 days"

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
