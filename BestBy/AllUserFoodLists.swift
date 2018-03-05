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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        listsTableView.delegate = self
        listsTableView.dataSource = self
        
        getListData()
        if(self.data.count < 2) {
            performSegue(withIdentifier: "pickAList", sender: listsTableView.dequeueReusableCell(withIdentifier: "ListCell"))
        }
    }

    func getListData() {
        for listID in currentUser.shared.allFood {
            ref.child("AllFoodLists").child(listID).observeSingleEvent(of: .value, with: { (snapshot) in
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
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "foodDetail") {
            let vc = segue.destination as! AllFoodViewController
            let cell = sender as! ListCell
            let idx = listsTableView.indexPath(for: cell)?.row
            listsTableView.deselectRow(at: listsTableView.indexPath(for: cell)!, animated: true)
            vc.currentListIdx = idx!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ListCell: UITableViewCell {
    @IBOutlet weak var listName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

