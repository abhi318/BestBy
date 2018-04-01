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
    var mustDelete = false
    
    @IBAction func shareSheetClicked(_ sender: Any) {
        let shareContent = currentListID
        let activityViewController = UIActivityViewController(activityItems: [shareContent!], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @IBOutlet weak var shoppingListTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // this isn't getting info quick enough... fix this tomorrow
        self.navigationItem.title = currentListName

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
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = currentUser.shared.allShoppingLists[self.currentListID]!.contents[indexPath.row]

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            currentUser.shared.allShoppingLists[self.currentListID]!.contents.remove(at: indexPath.row)
            Database.database().reference().child("AllShoppingLists/\(self.currentListID!)/\(item.ID)").removeValue()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let addToSpace = UITableViewRowAction(style: .normal, title: "Add") { (action, indexPath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addItemToSpaces") as! AddFoodToSpaceViewController
            vc.selected_food = item.name
            vc.selected_food_ID = item.ID
            vc.shoppingListID = self.currentListID
            vc.idx = indexPath
            vc.from = "AddToShopListViewController"
            
            self.show(vc, sender: self)
        }
        
        return [delete, addToSpace]
    }
}

