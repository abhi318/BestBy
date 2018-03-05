//
//  AllUserFoodLists.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/5/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AllUserFoodLists: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ref: DatabaseReference!
    
    private var data: [FoodList] = []
    
    @IBOutlet weak var listsTableView: UITableView!
    @IBAction func addNewList(_ sender: Any) {
        let alert = UIAlertController(title: "New List", message: "Give it a name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            let listRef = self.ref.child("AllFoodLists").childByAutoId()
            
            self.ref.child("FoodListInfo/\(listRef.key)/name").setValue(text)
            self.ref.child("FoodListInfo/\(listRef.key)/sharedWith/\(currentUser.shared.ID!)").setValue(true)
            self.ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs/\(listRef.key)").setValue(true)
            self.ref.child("AllFoodLists/\(listRef.key)").setValue(true)
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
        
        listsTableView.delegate = self
        listsTableView.dataSource = self
        
        observeUsersFoodLists()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "pickAList") {
            let vc = segue.destination as! AllFoodViewController
            
            let cell = sender as! ListCell
            vc.currentListID = cell.listID!
            currentUser.shared.currentListID = cell.listID!
            vc.currentListName = cell.listName.text!

            listsTableView.deselectRow(at: listsTableView.indexPath(for: cell)!, animated: true)
        }
    }

    func observeUsersFoodLists() {
        ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs").observe(.childAdded, with: { (snapshot) in
            let newFoodListID = snapshot.key
            self.getListData(listID: newFoodListID)
        })
    }
    
    func getListData(listID: String) {
        ref.child("FoodListInfo/\(listID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let listDict = snapshot.value as! [String: Any]
            let name = listDict["name"]
            let listItem = FoodList(id:snapshot.key, n: name as! String, shared:[])
            for (key, _) in listDict["sharedWith"] as! [String:Bool] {
                listItem.sharedWith.append(key)
            }
            
            self.data.append(listItem)
            DispatchQueue.main.async{
                self.listsTableView.reloadData()
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.data.count)
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        
        let ListItem = self.data[indexPath.row]
        
        cell.listName?.text = ListItem.name
        cell.listID = ListItem.ID
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let deletedFoodListID: String = self.data[indexPath.row].ID!
            self.ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs/\(deletedFoodListID)").removeValue()
            self.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.data[indexPath.row].name!)")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ListCell: UITableViewCell {
    @IBOutlet weak var listName: UILabel!
    
    var listID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

