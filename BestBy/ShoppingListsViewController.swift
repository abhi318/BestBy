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
    var inList = false
    var inListName = ""
    var sema = DispatchSemaphore(value: 0)
    
    @IBOutlet weak var shopListsTableView: UITableView!
    
    @IBAction func addShoppingList(_ sender: Any) {
        let alert = UIAlertController(title: "Add a New List", message: "Give it a name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            Database.database().reference().child("AllShoppingLists").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(text){
                    self.inListName = (snapshot.value as! [String: Any])["name"] as! String
                    self.inList = true
                }
                self.sema.signal()
            })
            
            DispatchQueue.global(qos: .background).async {
                self.sema.wait()
            
                if self.inList {
                    self.loadShoppingList(at: text)
                }
                else {
                    let listRef = self.ref.child("AllShoppingLists").childByAutoId()
                    
                    //listRef.setValue(["name": text])
                    self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listRef.key)").setValue(text)

                    currentUser.shared.shoppingListIDs.append(listRef.key)
                    
                    currentUser.shared.allShoppingLists[listRef.key] = ShoppingList()
                    currentUser.shared.allShoppingLists[listRef.key]!.name = text
                    
                    self.observeShoppingList(at: listRef.key)
                    DispatchQueue.main.async {
                        self.shopListsTableView.reloadData()
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadShoppingList(at: String) {
        let listRef = self.ref.child("AllShoppingLists\(at)")
        self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(at)").setValue(inListName)
        
        currentUser.shared.shoppingListIDs.append(listRef.key)
        
        currentUser.shared.allShoppingLists[listRef.key] = ShoppingList()
        currentUser.shared.allShoppingLists[listRef.key]!.name = inListName
        
        self.observeShoppingList(at: listRef.key)
        
        self.shopListsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.shopListsTableView.delegate = self
        self.shopListsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async{
            self.shopListsTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeShoppingList(at: String) {
        let ref: DatabaseReference = Database.database().reference().child("AllShoppingLists/\(at)")
        ref.observe(.childAdded, with: {snapshot in
            let foodInfo = snapshot.value as! String
            if snapshot.key != "name" {
                let newListItem = ListItem(id: snapshot.key,
                                           n: foodInfo)
                
                currentUser.shared.allShoppingLists[at]!.contents.append(newListItem)
            }
            
        })
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let listID = currentUser.shared.shoppingListIDs[indexPath.row]
        let list_for_row = currentUser.shared.allShoppingLists[listID]
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            currentUser.shared.shoppingListIDs.remove(at: indexPath.row)
            currentUser.shared.allShoppingLists.removeValue(forKey: listID)
            
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listID)").removeValue()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let addToSpace = UITableViewRowAction(style: .normal, title: "Add") { (action, indexPath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addItemToSpaces") as! AddFoodToSpaceViewController
            vc.selected_food = list_for_row?.name!

            vc.idx = indexPath
            vc.selected_food_ID = listID
            vc.from = "ShoppingListsViewController"
            
            var desc = ""
            for i in list_for_row!.contents {
                desc += "\(i.name), "
            }
            
            FoodData.food_data[list_for_row!.name!] = (10000, desc, UIImage(named: "groceries"))
            
            self.show(vc, sender: self)
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { (action, indexPath) in
            let shareContent = listID
            let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
            self.present(activityViewController, animated: true)
        }
        
        return [delete, addToSpace, share]
    }
    
}
