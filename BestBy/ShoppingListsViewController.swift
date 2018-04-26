//
//  ShoppingListsViewController.swift
//
//
//  Created by Erin Jensby on 2/27/18.
//



import UIKit
import FirebaseDatabase
import FirebaseStorage
import UIEmptyState

var addedSharedUsers: Set<String> = []

class ShoppingListsViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var ref: DatabaseReference!
    var handle: DatabaseHandle!
    var storageRef: StorageReference!
    
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
        
        let listRef = self.ref.child("AllShoppingLists").childByAutoId()
        listRef.child("name").setValue(text)
        listRef.child("sharedWith/\(currentUser.shared.ID!)").setValue(true)
        
        self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listRef.key)").setValue(text)
    
        isCreatingNewList = false
        textF.isHidden = true
        textF.resignFirstResponder()
        textF.text = ""
        
        DispatchQueue.main.async {
            self.shopListsTableView.reloadData()
            self.reloadEmptyStateForTableView(self.shopListsTableView)
        }
        
        return false
    }
    
    func loadShoppingList(at: String) {
        let listRef = self.ref.child("AllShoppingLists\(at)")
        
        listRef.child("sharedWith/\(currentUser.shared.ID!)").setValue(true)
        self.ref.child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(at)").setValue(inListName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.shopListsTableView.delegate = self
        self.shopListsTableView.dataSource = self
        
        self.shopListsTableView.allowsSelection = true

        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        shopListsTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.navigationItem.title = "Shopping Lists"
        
        isCreatingNewList = false
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadEmptyStateForTableView(shopListsTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.shopListsTableView.indexPathForSelectedRow {
            self.shopListsTableView.deselectRow(at: index, animated: true)
        }
        observeShoppingLists()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentUser.shared.userRef!.child("ShoppingLists").removeObserver(withHandle: handle)
        for ID in currentUser.shared.shoppingListIDs {
            ref.child("AllShoppingLists/\(ID)/sharedWith").removeAllObservers()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeShoppingLists() {
        
//        let picsDownloaded = DispatchSemaphore(value:0)
        
        let userShoppingListref: DatabaseReference = currentUser.shared.userRef!.child("ShoppingLists")
        handle = userShoppingListref.observe(.childAdded, with: {snapshot in
            let listName = snapshot.value as! String
            if !addedShoppingLists.contains(snapshot.key) {
                addedShoppingLists.insert(snapshot.key)
                currentUser.shared.shoppingListIDs.append(snapshot.key)
                currentUser.shared.allShoppingLists[snapshot.key] = ShoppingList()
                currentUser.shared.allShoppingLists[snapshot.key]!.name = listName
                
                DispatchQueue.main.async{
                    self.shopListsTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.shopListsTableView)
                }
            }
        })
        
        for ID in currentUser.shared.shoppingListIDs {
            ref.child("AllShoppingLists/\(ID)/sharedWith").observe(.childAdded, with: {(snapshot) in
                print(snapshot)
                print(ID)
                print(self.ref.child("AllShoppingLists/\(ID)/sharedWith"))

                let hasSharedUser = currentUser.shared.allShoppingLists[ID]!.sharedWithSET.contains(snapshot.key)
                
                if snapshot.key != currentUser.shared.ID && !hasSharedUser{
                    currentUser.shared.allShoppingLists[ID]!.sharedWithSET.insert(snapshot.key)
                    let profImageRef = self.storageRef.child("profImages/\(snapshot.key).png")
                    
                    profImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if error != nil {
                            currentUser.shared.allShoppingLists[ID]!.sharedWith.append((snapshot.key, UIImage(named: "default_profile.png")!))
                        } else {
                            currentUser.shared.allShoppingLists[ID]!.sharedWith.append((snapshot.key, UIImage(data: data!)!))
                        }
                        DispatchQueue.main.async{
                            self.shopListsTableView.reloadData()
                            self.reloadEmptyStateForTableView(self.shopListsTableView)
                        }
                    }
                }
            })
        }
        
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
        self.reloadEmptyStateForTableView(shopListsTableView)

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
     }
    
}

extension ShoppingListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCreatingNewList {
            return currentUser.shared.shoppingListIDs.count + 1
        }
        return currentUser.shared.shoppingListIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopListID") as! ShoppingListCellTableViewCell
        
        cell.shareWithTextField.isHidden = true
        if isCreatingNewList {
            if indexPath.item + 1 == tableView.numberOfRows(inSection: 0) {
                cell.newListTextField.delegate = self
                cell.listNameLabel.text = ""
                cell.newListTextField.isHidden = false
                cell.newListTextField.becomeFirstResponder()
                cell.shareListButton.isHidden = true
            } else {
                let listID = currentUser.shared.shoppingListIDs[indexPath.item]
                let list_for_row = currentUser.shared.allShoppingLists[listID]
                let name = list_for_row?.name
                cell.listNameLabel.text = name
                cell.newListTextField.isHidden = true
                cell.listID = listID
            }
        } else {
            let listID = currentUser.shared.shoppingListIDs[indexPath.item]
            let list_for_row = currentUser.shared.allShoppingLists[listID]
            let name = list_for_row?.name
            cell.listNameLabel.text = name
            cell.newListTextField.isHidden = true
            cell.listID = listID
            cell.shareListButton.isHidden = false
        }
        
        cell.listNameLabel.sizeToFit()
        
        return cell
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
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let listID = currentUser.shared.shoppingListIDs[indexPath.row]
        
        let transferAction = UIContextualAction(style: .destructive, title:  "Add To Pantry", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
            
            let ref = Database.database().reference()
            ref.child("AllShoppingLists/\(listID)").observeSingleEvent(of: .value, with:  { (snapshot) in
                print(snapshot)
                let info = snapshot.value as! [String:Any]
                for (id, name) in info {
                    if id == "name" || id == "sharedWith" {continue}
                    let foodName = name as! String
                    var daysToExpire = -2
                    
                    if FoodData.food_data[foodName] != nil {
                        daysToExpire = FoodData.food_data[foodName]!.0
                    } else {
                        FoodData.food_data[foodName] = (daysToExpire, "", UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal))
                        self.ref.child("Users/\(currentUser.shared.ID!)/ExtraFoods/\(foodName)").setValue(["doe": daysToExpire,
                                                                                                            "desc": ""])
                    }
                    
                    if daysToExpire <= 0 {
                        daysToExpire = 10000
                    }
                    
                    let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
                    let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
                    let doe = Int(timeInterval!)

                    let post = ["name" : foodName,
                                "timestamp" : doe] as [String : Any]
                    
                    self.ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
                    
                    if daysToExpire < 1000 {
                        getNotificationForDay(on: dateOfExpiration!, foodName: foodName)
                    }
                }
            })
            
            currentUser.shared.shoppingListIDs.remove(at: indexPath.row)
            currentUser.shared.allShoppingLists.removeValue(forKey: listID)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadEmptyStateForTableView(self.shopListsTableView)

            currentUser.shared.userRef!.child("ShoppingLists/\(listID)").removeValue()
            success(true)
        })
        transferAction.image = UIImage(named: "tick")
        transferAction.backgroundColor = gradient[2]
        return UISwipeActionsConfiguration(actions: [transferAction])
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let listID = currentUser.shared.shoppingListIDs[indexPath.row]
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            
            currentUser.shared.shoppingListIDs.remove(at: indexPath.row)
            let x = currentUser.shared.allShoppingLists.removeValue(forKey: listID)
            if x!.sharedWith.count == 0 {
                Database.database().reference().child("AllShoppingLists/\(listID)").removeValue()
            }
            
            Database.database().reference().child("Users/\(currentUser.shared.ID!)/ShoppingLists/\(listID)").removeValue()
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.reloadEmptyStateForTableView(tableView)
        }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableCell = cell as? ShoppingListCellTableViewCell else { return }
        
        if isCreatingNewList && indexPath.item + 1 == tableView.numberOfRows(inSection: 0) {
            tableCell.sharedWithCollectionView.isHidden = true
        }
        else {
            tableCell.sharedWithCollectionView.isHidden = false
            tableCell.sharedWithCollectionView.sendSubview(toBack: tableCell)
            tableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            tableCell.sharedWithCollectionView.isUserInteractionEnabled = false
        }

    }
    
}

extension ShoppingListsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let x = currentUser.shared.shoppingListIDs[collectionView.tag]
        return currentUser.shared.allShoppingLists[x]!.sharedWith.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! sharedWithCell

        cell.imageView.image = currentUser.shared.allShoppingLists[currentUser.shared.shoppingListIDs[collectionView.tag]]!.sharedWith[indexPath.item].1
        cell.layer.cornerRadius = cell.frame.width/2
        cell.clipsToBounds = true
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }
}

extension ShoppingListsViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    var emptyStateImage: UIImage? {
        return UIImage(named: "list_512")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:22.0)!]
        return NSAttributedString(string: "No Shopping Lists Yet", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white,
                     NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size:16.0)!]
        return NSAttributedString(string: "Make One", attributes: attrs)
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
        isCreatingNewList = true
        shopListsTableView.reloadData()
        self.reloadEmptyStateForTableView(shopListsTableView)
    }
}
