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
import UIEmptyState
import UserNotifications

class AddToShopListViewController: UIViewController {

    private var data: [FoodItem] = []
    var userFoodRef: DatabaseReference!
    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    
    var currentListID: String!
    var currentListName: String!
    var mustDelete = false
    
    @IBOutlet weak var shoppingListTableView: UITableView!
    
    @IBAction func transferSelectedClicked(_ sender: Any) {
        print("OK, marked as Closed")
        for idx in shoppingListTableView.indexPathsForSelectedRows! {
            let item = currentUser.shared.allShoppingLists[self.currentListID]!.contents[idx.row]
            
            var daysToExpire = -2
            
            if FoodData.food_data[item.name] != nil{
                daysToExpire = FoodData.food_data[item.name]!.0
            }
                
            else {
                FoodData.food_data[item.name] = (daysToExpire, "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
                self.ref.child("Users/\(currentUser.shared.ID!)/ExtraFoods/\(item.name)").setValue(["doe": daysToExpire,
                                                                                                    "desc": ""])
            }
            
            if daysToExpire <= 0 {
                daysToExpire = 10000
            }
            
            let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
            let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
            let doe = Int(timeInterval!)
            
            let post = ["name" : item.name,
                        "timestamp" : doe] as [String : Any]
            
            self.ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
            if daysToExpire < 1000 {
                getNotificationForDay(on: dateOfExpiration!, foodName: item.name)
            }
            Database.database().reference().child("AllShoppingLists/\(self.currentListID!)/\(item.ID)").removeValue()
        }
        for idx in shoppingListTableView.indexPathsForSelectedRows!.sorted(by: >) {
            currentUser.shared.allShoppingLists[self.currentListID]!.contents.remove(at: idx.row)
            
            shoppingListTableView.deleteRows(at: [idx], with: .fade)
            self.reloadEmptyStateForTableView(shoppingListTableView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyStateDelegate = self
        self.emptyStateDataSource = self
        
        shoppingListTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        
        self.shoppingListTableView.allowsSelection = true
        self.shoppingListTableView.allowsMultipleSelection = true
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // this isn't getting info quick enough... fix this tomorrow
        super.viewWillAppear(animated)
        observeShoppingList()
        self.navigationItem.title = currentListName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(shoppingListTableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.child("AllShoppingLists/\(currentListID!)").removeObserver(withHandle: handle)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func observeShoppingList() {
        let curRef = ref.child("AllShoppingLists/\(currentListID!)")
        handle = curRef.observe(.childAdded, with: {(snapshot) in
            if snapshot.key != "name" && snapshot.key != "sharedWith" && !foodAddedToShoppingList.contains(snapshot.key)
            {
                foodAddedToShoppingList.insert(snapshot.key)
                
                currentUser.shared.allShoppingLists[self.currentListID]!.contents.append(ListItem(id: snapshot.key, n: snapshot.value as! String))
            }
            DispatchQueue.main.async {
                self.shoppingListTableView.reloadData()
                self.reloadEmptyStateForTableView(self.shoppingListTableView)
            }
        })
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
        cell.selectionStyle = .none
        let foodItem = currentUser.shared.allShoppingLists[currentListID]!.contents[indexPath.row]
        cell.textLabel!.text = foodItem.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let item = currentUser.shared.allShoppingLists[self.currentListID]!.contents[indexPath.row]
        
        let transferAction = UIContextualAction(style: .destructive, title:  "Transfer", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
            
            var daysToExpire = -2
            
            if FoodData.food_data[item.name] != nil{
                daysToExpire = FoodData.food_data[item.name]!.0
            }
                
            else {
                FoodData.food_data[item.name] = (daysToExpire, "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
                self.ref.child("Users/\(currentUser.shared.ID!)/ExtraFoods/\(item.name)").setValue(["doe": daysToExpire,
                                                                                                    "desc": ""])
            }
            
            if daysToExpire <= 0 {
                daysToExpire = 10000
            }
            
            let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
            let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
            let doe = Int(timeInterval!)
            
            let post = ["name" : item.name,
                        "timestamp" : doe] as [String : Any]
            
            self.ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
            if daysToExpire < 1000 {
                getNotificationForDay(on: dateOfExpiration!, foodName: item.name)
            }
            
            currentUser.shared.allShoppingLists[self.currentListID]!.contents.remove(at: indexPath.row)
            Database.database().reference().child("AllShoppingLists/\(self.currentListID!)/\(item.ID)").removeValue()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadEmptyStateForTableView(tableView)
            success(true)
        })
        transferAction.image = UIImage(named: "tick")
        transferAction.backgroundColor = gradient[2]
        return UISwipeActionsConfiguration(actions: [transferAction])
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = currentUser.shared.allShoppingLists[self.currentListID]!.contents[indexPath.row]

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            currentUser.shared.allShoppingLists[self.currentListID]!.contents.remove(at: indexPath.row)
            Database.database().reference().child("AllShoppingLists/\(self.currentListID!)/\(item.ID)").removeValue()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadEmptyStateForTableView(self.shoppingListTableView)
        }
        
        return [delete]
    }
}

extension AddToShopListViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    var emptyStateImage: UIImage? {
        return UIImage(named: "basket_512")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:22.0)!]
        return NSAttributedString(string: "No Items in \(currentListName!) yet", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:16.0)!]
        return NSAttributedString(string: "Add Some", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 100, height: 40)
    }
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        
        emptyView.button.layer.cornerRadius = 5
        emptyView.button.layer.borderWidth = 1
        emptyView.button.layer.borderColor = gradient[4].cgColor
        emptyView.button.layer.backgroundColor = gradient[2].cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        performSegue(withIdentifier: "segueToAddFood", sender: self)
    }
}

