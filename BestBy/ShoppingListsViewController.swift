//
//  ShoppingListsViewController.swift
//
//
//  Created by Erin Jensby on 2/27/18.
//

import UIKit
import Firebase
import FirebaseDatabase

class ShoppingListsViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var ref: DatabaseReference!
    
    var selectedListID: String!
    var selectedListName: String!
    var inList = false
    var inListName = ""
    var sema = DispatchSemaphore(value: 0)
    
    var isCreatingNewList = false
    
    @IBOutlet weak var shopListsTableView: UITableView!
    @IBAction func addShoppingList(_ sender: Any) {
        isCreatingNewList = true
        shopListsTableView.reloadData()
    }

    func textFieldShouldReturn(_ textF: UITextField) -> Bool {
        let text = textF.text
        Database.database().reference().child("AllShoppingLists/\(String(describing: text))").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                let info = (snapshot.value as! [String: Any])
                self.inListName = info["name"] as! String
                self.inList = true
            }
            self.sema.signal()
        })
        
        DispatchQueue.global(qos: .background).async {
            self.sema.wait()
            
            if self.inList {
                self.loadShoppingList(at: text!)
            }
            else {
                let listRef = self.ref.child("AllShoppingLists").childByAutoId()
                listRef.child("name").setValue(text)
                
                self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listRef.key)").setValue(text)
                
                currentUser.shared.shoppingListIDs.append(listRef.key)
                
                currentUser.shared.allShoppingLists[listRef.key] = ShoppingList()
                currentUser.shared.allShoppingLists[listRef.key]!.name = text
                
                self.observeShoppingList(at: listRef.key)
            }
            
            DispatchQueue.main.async {
                self.shopListsTableView.reloadData()
            }
        }
        
        isCreatingNewList = false
        textF.isHidden = true
        textF.resignFirstResponder()
        
        shopListsTableView.reloadData()
        
        return false
    }
    
    func loadShoppingList(at: String) {
        let listRef = self.ref.child("AllShoppingLists\(at)")
        self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(at)").setValue(inListName)
        
        currentUser.shared.shoppingListIDs.append(listRef.key)
        
        currentUser.shared.allShoppingLists[listRef.key] = ShoppingList()
        currentUser.shared.allShoppingLists[listRef.key]!.name = inListName
        
        self.observeShoppingList(at: listRef.key)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.shopListsTableView.delegate = self
        self.shopListsTableView.dataSource = self
        
        self.navigationItem.title = "Shopping Lists"
        
        isCreatingNewList = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
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
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isKind(of: UIControl.self))! {
            return false
        }
        isCreatingNewList = false
        shopListsTableView.reloadData()
        self.dismissKeyboard()
        return true
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
        if isCreatingNewList {
            return currentUser.shared.allShoppingLists.count + 1
        }
        return currentUser.shared.allShoppingLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopListID") as? ShoppingListCellTableViewCell
        
        if isCreatingNewList {
            if indexPath.item + 1 == tableView.numberOfRows(inSection: 0) {
                cell?.newListTextField.delegate = self
                cell?.listNameLabel.text = ""
                cell?.newListTextField.isHidden = false
                cell?.newListTextField.becomeFirstResponder()
            } else {
                let listID = currentUser.shared.shoppingListIDs[indexPath.item]
                let list_for_row = currentUser.shared.allShoppingLists[listID]
                let name = list_for_row?.name
                cell?.listNameLabel.text = name
                cell?.newListTextField.isHidden = true
            }
        } else {
            let listID = currentUser.shared.shoppingListIDs[indexPath.item]
            let list_for_row = currentUser.shared.allShoppingLists[listID]
            let name = list_for_row?.name
            cell?.listNameLabel.text = name
            cell?.newListTextField.isHidden = true

        }
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
            let shareContent = "\(Auth.auth().currentUser!.email!) is shared a shopping list with you: \n\(listID)" 
            let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
            self.present(activityViewController, animated: true)
        }
        
        return [delete, addToSpace, share]
    }
    
}
