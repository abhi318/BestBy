//
//  ShoppingListsViewController.swift
//
//
//  Created by Erin Jensby on 2/27/18.
//

import UIKit
import Firebase
import FirebaseDatabase

class ShoppingListsViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var selectedListID: String!
    var selectedListName: String!
    
    @IBOutlet weak var shopListsTableView: UITableView!
    
    @IBAction func addShoppingList(_ sender: Any) {
        let alert = UIAlertController(title: "New List", message: "Give it a name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            let listRef = self.ref.child("AllShoppingLists").childByAutoId()
            
            self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listRef.key)").setValue(text)
            //self.ref.child("AllShoppingLists/\(listRef.key)").setValue(text)
            
            currentUser.shared.shoppingListIDs.append(listRef.key)
            
            currentUser.shared.allShoppingLists[listRef.key] = ShoppingList()
            currentUser.shared.allShoppingLists[listRef.key]!.name = text
            
            self.shopListsTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.shopListsTableView.delegate = self
        self.shopListsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToShoppingList" {
            if let destinationVC = segue.destination as? AddToShopListViewController {
                let key1 = selectedListID
                let key2 = selectedListName
                destinationVC.currentListID = key1
                destinationVC.currentListName = key2
            }
        }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
}

extension ShoppingListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUser.shared.allShoppingLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopListID") as? ShoppingListCellTableViewCell
        
        let listID = currentUser.shared.shoppingListIDs[indexPath.item]
        let list_for_row = currentUser.shared.allShoppingLists[listID]
        let name = list_for_row?.name
        cell?.listNameLabel.text = name
        return cell!
    }
    
    func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let listID = currentUser.shared.shoppingListIDs[indexPath.item]
        let list_for_row = currentUser.shared.allShoppingLists[listID]
        let name = list_for_row?.name
        selectedListID = listID
        selectedListName = name
        return indexPath
    }
}
