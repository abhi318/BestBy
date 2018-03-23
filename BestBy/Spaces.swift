////
////  Spaces.swift
////  BestBy
////
////  Created by Abhinav Sangisetti on 3/5/18.
////  Copyright © 2018 Quatro. All rights reserved.
////
//
//import UIKit
//import Firebase
//import FirebaseDatabase
//
//class Spaces: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    var ref: DatabaseReference!
//
//    @IBOutlet weak var listsTableView: UITableView!
//    @IBAction func addNewList(_ sender: Any) {
//        let alert = UIAlertController(title: "New List", message: "Give it a name", preferredStyle: .alert)
//        let saveAction = UIAlertAction(title: "Add", style: .default) { _ in
//            guard let textField = alert.textFields?.first,
//                let text = textField.text else { return }
//            
//            let listRef = self.ref.child("AllFoodLists").childByAutoId()
//
//            self.ref.child("FoodListInfo/\(listRef.key)/name").setValue(text)
//            self.ref.child("FoodListInfo/\(listRef.key)/sharedWith/\(currentUser.shared.ID!)").setValue(true)
//            self.ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs/\(listRef.key)").setValue(true)
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .default)
//
//        alert.addTextField()
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        ref = Database.database().reference()
//
//        listsTableView.delegate = self
//        listsTableView.dataSource = self
//
//        self.title = "Spaces"
//        
//        if(currentUser.shared.allSpaces.count == 1) {
//            observeUsersFoodLists()
//        }
//    }
//
//    func observeUsersFoodLists() {
//        ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs").observe(.childAdded, with: { (snapshot) in
//            let newFoodListID = snapshot.key
//            self.getListData(listID: newFoodListID)
//        })
//    }
//
//    func getListData(listID: String) {
//        ref.child("FoodListInfo/\(listID)").observeSingleEvent(of: .value, with: { (snapshot) in
//            let listInfo = snapshot.value as! [String: Any]
//            let name = listInfo["name"] as! String
//            let listItem = FoodList(id:snapshot.key, n: name, shared:[])
//            for (key, _) in listInfo["sharedWith"] as! [String:Bool] {
//                listItem.sharedWith.append(key)
//            }
//
//            currentUser.shared.allSpaces[snapshot.key] = (listItem)
//
//            DispatchQueue.main.async{
//                self.listsTableView.reloadData()
//            }
//        })
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentUser.shared.allSpaces.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
//
//
//        let ListItem = currentUser.shared.allSpaces[Array(currentUser.shared.allSpaces.keys)[indexPath.row]]
//        
//        cell.listName?.text = ListItem?.name
//        cell.listID = ListItem?.ID
//        
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let presenter = navigationController?.childViewControllers[0] as? AllFoodViewController {
//            let keyAtIndex = Array(currentUser.shared.allSpaces.keys)[indexPath.row]
//            presenter.currentListID = currentUser.shared.allSpaces[keyAtIndex]?.ID
//            presenter.currentListName = currentUser.shared.allSpaces[keyAtIndex]?.name
//        }
//        _ = navigationController?.popViewController(animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let keyAtIndex = Array(currentUser.shared.allSpaces.keys)[indexPath.row]
//
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            // delete item at indexPath
//            let deletedFoodListID: String = currentUser.shared.allSpaces[keyAtIndex]!.ID!
//            self.ref.child("Users/\(currentUser.shared.ID!)/UserFoodListIDs/\(deletedFoodListID)").removeValue()
//            currentUser.shared.allSpaces.removeValue(forKey: keyAtIndex)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//
//        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
//            // share item at indexPath
//            print("I want to share: \(String(describing: currentUser.shared.allSpaces[keyAtIndex]?.name!))")
//        }
//
//        share.backgroundColor = UIColor.lightGray
//
//        return [delete, share]
//        
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if(indexPath.row == 0) {
//            return false
//        }
//        return true
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//}
//
//class ListCell: UITableViewCell {
//    @IBOutlet weak var listName: UILabel!
//    //@IBOutlet private weak var collectionOfFoods: UICollectionView!
//
//    var listID: String!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//
////    func setCollectionViewDataSourceDelegate
////        <D: UICollectionViewDataSource & UICollectionViewDelegate>
////        (dataSourceDelegate: D, forRow row: Int) {
////
////        collectionView.delegate = dataSourceDelegate
////        collectionView.dataSource = dataSourceDelegate
////        collectionView.tag = row
////        collectionView.reloadData()
////    }
//}
//
//
//
//////
//////  SpacesCollectionViewController.swift
//////  BestBy
//////
//////  Created by Abhinav Sangisetti on 3/21/18.
//////  Copyright © 2018 Quatro. All rights reserved.
//////
////import HFCardCollectionViewLayout
////import UIKit
////
////private let reuseIdentifier = "Cell"
////
////class SpacesCollectionViewController: UICollectionViewController, HFCardCollectionViewLayoutDelegate{
////
////    var cardCollectionViewLayout: HFCardCollectionViewLayout?
////
////    @IBOutlet var backgroundView: UIView?
////    @IBOutlet var backgroundNavigationBar: UINavigationBar?
////
////    //var cardLayoutOptions: CardLayoutSetupOptions?
////    var shouldSetupBackgroundView = false
////
////    var a:[String] = [String]()
////
////    override func viewDidLoad() {
////        //self.setupExample()
////        super.viewDidLoad()
////    }
////
////    // MARK: CollectionView
////
//////    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willRevealCardAtIndex index: Int) {
//////        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? SpacesCollectionViewCell {
//////            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
//////            cell.cardIsRevealed(true)
//////        }
//////    }
////
//////    func cardCollectionViewLayout(_ collectionViewLayout: HFCardCollectionViewLayout, willUnrevealCardAtIndex index: Int) {
//////        if let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? SpacesCollectionViewCell {
////////            cell.cardCollectionViewLayout = self.cardCollectionViewLayout
////////            cell.cardIsRevealed(false)
//////        }
//////    }
////
////    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return 30
////    }
////
////    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SpacesCollectionViewCell
////        cell.testLabel.text = "hfdsa"
////        return cell
////    }
////
////    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        self.cardCollectionViewLayout?.revealCardAt(index: indexPath.item)
////    }
////
//////    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
////////        let tempItem = self.cardArray[sourceIndexPath.item]
////////        self.cardArray.remove(at: sourceIndexPath.item)
////////        self.cardArray.insert(tempItem, at: destinationIndexPath.item)
//////    }
////
////}
////
////class SpacesCollectionViewCell: HFCardCollectionViewCell {
////
////    @IBOutlet weak var testLabel: UILabel!
////    @IBOutlet weak var sharedWithCollectionView: UICollectionView!
////
////    @IBOutlet weak var listContents: UITableView!
////
////
////    override func awakeFromNib() {
////        super.awakeFromNib()
////
////        self.listContents?.scrollsToTop = false
////
////        self.listContents?.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
////        self.listContents?.dataSource = self
////        self.listContents?.delegate = self
////        self.listContents?.reloadData()
////    }
////
////}
////
////extension SpacesCollectionViewCell : UITableViewDelegate, UITableViewDataSource  {
////    func numberOfSections(in tableView: UITableView) -> Int {
////        return 1
////    }
////
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return 20
////    }
////
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell")
////        cell?.textLabel?.text = "Table Cell #\(indexPath.row)"
////        cell?.textLabel?.textColor = .white
////        cell?.backgroundColor = .clear
////        cell?.selectionStyle = .none
////        return cell!
////    }
////}
////
//

