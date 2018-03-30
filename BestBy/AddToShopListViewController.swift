//
//  AddToShopListViewController.swift
//  BestBy
//
//  Created by Erin Jensby on 3/30/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddToShopListViewController: UIViewController {

    private var data: [FoodItem] = []
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    
    var currentListID: String!
    var currentListName: String!

    @IBOutlet weak var shoppingListTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // this isn't getting info quick enough... fix this tomorrow
        shoppingListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToAddFood" {
            if let destinationVC = segue.destination as? AddFoodToShopListViewController {
                let key1 = currentListID
                destinationVC.currentListID = key1!
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension AddToShopListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentUser.shared.allShoppingLists[currentListID] != nil {
            return currentUser.shared.allShoppingLists[currentListID]!.contents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listItemID", for: indexPath)

        let foodItem = currentUser.shared.allShoppingLists[currentListID]!.contents[indexPath.row]
        cell.textLabel!.text = foodItem.name
        cell.detailTextLabel?.text = String(foodItem.amount)
        return cell
    }
}

