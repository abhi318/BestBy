import UIKit
import FirebaseDatabase

private let reuseIdentifier = "Cell"

class FoodCollectionController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    var filteredFood = Array(FoodData.food_data.keys)
    var allFood = Array(FoodData.food_data.keys)
    var searchActive : Bool = false
    var foodBeingAdded: String?
    var flag: Bool = false
    var isEditingFoods: Bool = false
    var handle: DatabaseHandle!
    
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var pickShoppingListView: UIView!
    @IBOutlet var didAdd: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var isEditingNavButon: UIBarButtonItem!
    @IBAction func editFoodsClicked(_ sender: Any) {
        if isEditingNavButon.title == "Edit" {
            isEditingNavButon.title = "Cancel"
            isEditingFoods = true
        }
        else {
            isEditingNavButon.title = "Edit"
            isEditingFoods = false
        }
        collectionView.reloadData()
    }
    
    func observeExtraFoods() {
        let userRef: DatabaseReference = currentUser.shared.userRef!
        handle = userRef.child("ExtraFoods").observe(.childAdded, with: { (snapshot) in
            let extraItemInfo = snapshot.value as! [String : Any]
            if FoodData.food_data[snapshot.key] != nil {
                FoodData.food_data[snapshot.key]!.0 = extraItemInfo["doe"] as! Int
                FoodData.food_data[snapshot.key]!.1 = extraItemInfo["desc"] as! String
            } else {
                FoodData.food_data[snapshot.key] = (extraItemInfo["doe"] as! Int, extraItemInfo["desc"] as! String, UIImage(named: "groceries"))
            }
            self.allFood = Array(FoodData.food_data.keys)
            self.filteredFood = self.allFood
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.didAdd.alpha = 0.0
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar.delegate = self
        
        listPicker.delegate = self
        listPicker.dataSource = self
        
        didAdd.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        flag = false
        self.navigationItem.title = "All Items"
        searchBar.text = ""
        filteredFood = allFood
        searchBar.placeholder = "Search Foods"
        pickShoppingListView.isHidden = true
        
        observeExtraFoods()
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentUser.shared.userRef!.child("ExtraFoods").removeObserver(withHandle: handle)
        if(collectionView!.indexPathsForSelectedItems!.count > 0) {
            if let cell = collectionView?.cellForItem(at: (collectionView?.indexPathsForSelectedItems![0])!) {
                let c = cell as! CollectionCell
                c.addToShoppingList.isHidden = true
                c.addToSpace.isHidden = true
            }
        }
    }
    
    @IBAction func listButtonClicked(_ sender: Any) {
        if currentUser.shared.shoppingListIDs.count == 0 {
            self.tabBarController?.selectedIndex = 1
        } else if currentUser.shared.shoppingListIDs.count == 1 {
            let currentListID = currentUser.shared.shoppingListIDs[0]
            let ref = Database.database().reference()
            let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
            ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(self.navigationItem.title)
            
            didAdd.text = "Added to \(currentUser.shared.allShoppingLists[currentListID]!.name!)"
            UIView.animate(withDuration: 0.2, animations: {
                self.didAdd.alpha = 1.0
            },completion: { finished in
                UIView.animate(withDuration: 0.2, delay: 1, options: [], animations: {
                    self.didAdd.alpha = 0.0
                },completion: nil)
            })
        } else {
            pickShoppingListView.isHidden = false
        }
    }
    
    @IBAction func addToSelectedList(_ sender: UIButton?) {
        
        let list_idx = listPicker.selectedRow(inComponent: 0)
        let currentListID = currentUser.shared.shoppingListIDs[list_idx]
        
        let tag = sender?.tag
        let cell = collectionView.cellForItem(at: IndexPath(item: tag!, section: 0)) as! CollectionCell
        
        let foodAdded: String = cell.foodName.text!

        let ref = Database.database().reference()

        let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
        ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(foodAdded)

        pickShoppingListView.isHidden = true
        cell.addToShoppingList.isHidden = true
        cell.addToSpace.isHidden = true

        didAdd.text = "Added to \(currentUser.shared.allShoppingLists[currentListID]!.name!)"
        UIView.animate(withDuration: 0.2, animations: {
            self.didAdd.alpha = 1.0
        },completion: { finished in
            UIView.animate(withDuration: 0.2, delay: 1, options: [], animations: {
                self.didAdd.alpha = 0.0
            },completion: nil)
        })
        
    }
    
    @objc func buttonClicked(sender: UIButton?) {
        let tag = sender?.tag
        let cell = collectionView.cellForItem(at: IndexPath(item: tag!, section: 0)) as! CollectionCell
        
        let foodAdded: String = cell.foodName.text!
        
        var daysToExpire = FoodData.food_data[foodAdded]!.0
        
        let ref = Database.database().reference()
        
        if daysToExpire <= 0 {
            daysToExpire = 10000
        }
        
        let dateOfExpiration = Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())
        let timeInterval = dateOfExpiration?.timeIntervalSinceReferenceDate
        let doe = Int(timeInterval!)
        
        //post name of food, and seconds from reference date (jan 1, 2001) that it will expire
        let post = ["name" : foodAdded,
                    "timestamp" : doe] as [String : Any]
        
        ref.child("AllFoodLists/\(currentUser.shared.allFoodListID!)").childByAutoId().setValue(post)
        
        if daysToExpire < 1000 {
            getNotificationForDay(on: dateOfExpiration!, foodName: foodAdded)
        }
        cell.addToShoppingList.isHidden = true
        cell.addToSpace.isHidden = true
        
        didAdd.text = "Added to Pantry"
        UIView.animate(withDuration: 0.2, animations: {
            self.didAdd.alpha = 1.0
        },completion: { finished in
            UIView.animate(withDuration: 0.2, delay: 1, options: [], animations: {
                self.didAdd.alpha = 0.0
            },completion: nil)
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                            sender: Any?) -> Bool {
        if identifier == "addNewFood" && flag {
            return true
        }
        if identifier == "addToShoppingList"  {
            if currentUser.shared.shoppingListIDs.count == 0 {
                self.tabBarController?.selectedIndex = 1
                return false
            } else if currentUser.shared.shoppingListIDs.count == 1 {
                let currentListID = currentUser.shared.shoppingListIDs[0]
                let ref = Database.database().reference()
                let listRef = ref.child("AllShoppingLists/\(currentListID)").childByAutoId()
                ref.child("AllShoppingLists/\(currentListID)/\(listRef.key)").setValue(self.navigationItem.title)
                
                didAdd.text = "Added to \(currentUser.shared.allShoppingLists[currentListID]!.name!)"
                UIView.animate(withDuration: 0.2, animations: {
                    self.didAdd.alpha = 1.0
                },completion: { finished in
                    UIView.animate(withDuration: 0.2, delay: 1, options: [], animations: {
                        self.didAdd.alpha = 0.0
                    },completion: nil)
                })
                
                
                return false
            }
            return true
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToShoppingList" {
            if let destinationVC = segue.destination as? AddFoodToListFromCollectionViewController {
                destinationVC.selected_food = self.navigationItem.title
            }
        }
        
        if segue.identifier == "addNewFood" {
            if let button = sender as? UIButton {
                let cell = button.superview?.superview as! CollectionCell
                let controller = segue.destination as! AddNewFoodController
                
                controller.foodName = cell.foodName.text
                controller.foodDesc = FoodData.food_data[cell.foodName.text!]!.1
                controller.doe = FoodData.food_data[cell.foodName.text!]!.0
                controller.im = cell.imageView.image
            }
        }
    }
}


extension FoodCollectionController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let names = allFood
        if searchText == "" {
            searchActive = false
            filteredFood = allFood
            collectionView.reloadData()
            return
        }
        searchActive = true
        filteredFood = names.filter({( food_name : String) -> Bool in
            return food_name.lowercased().contains(searchText.lowercased())
        })
        collectionView.reloadData()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView.reloadData()
        searchBar.resignFirstResponder()
    }
}

extension FoodCollectionController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredFood.count + 1
    }
    
    @objc func makeSegue(button:UIButton) {
        self.performSegue(withIdentifier: "addNewFood", sender: button)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        var count = filteredFood.count
        
        cell.addToSpace.tag = indexPath.row
        cell.addToSpace.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
        
        if isEditingFoods && indexPath.row != count{
            cell.editFoodButton.isHidden = false
            cell.imageView.alpha = 0.4
            collectionView.allowsSelection = false
            cell.editFoodButton.addTarget(self, action: #selector(self.makeSegue), for: UIControlEvents.touchUpInside)
        } else {
            cell.editFoodButton.isHidden = true
            cell.imageView.alpha = 1.0
            collectionView.allowsSelection = true
        }
        
        var key:String
        
        if cell.isSelected {
            cell.addToSpace.isHidden = false
            cell.addToShoppingList.isHidden = false
        }
        else {
            cell.addToSpace.isHidden = true
            cell.addToShoppingList.isHidden = true
        }
        
        count = filteredFood.count
        if indexPath.row == count {
            cell.imageView.image = UIImage(named:"add.png")
            cell.addToSpace.isHidden = true
            cell.addToShoppingList.isHidden = true
            cell.foodName.text = "Add New"
            return cell
        }
        
        key = filteredFood[indexPath.row]
        
        if FoodData.food_data[key] != nil{
            cell.imageView.image = FoodData.food_data[key]!.2
        } else {
            FoodData.food_data[key]!.2 = UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal)
            cell.imageView.image = FoodData.food_data[key]!.2
        }
        cell.foodName.text = key
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionCell
        
        var key:String
        var count: Int
        flag = false
        if searchActive {
            count = filteredFood.count
            if indexPath.row == count {
                flag = true
                performSegue(withIdentifier: "addNewFood", sender: self)
                return
            }
            key = filteredFood[indexPath.row]
        }
        else {
            count = allFood.count
            if indexPath.row == count {
                flag = true
                performSegue(withIdentifier: "addNewFood", sender: self)
                return
            }
            
            key = allFood[indexPath.row]
        }
        
        self.navigationItem.title = cell.foodName.text
        var daysRemaining = -1
        
        if FoodData.food_data[key] != nil {
            daysRemaining = FoodData.food_data[key]!.0
            if FoodData.food_data[key]!.0 < 0 {
                daysRemaining = 10000
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1,
                       initialSpringVelocity: 5, options: [],
                       animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1,
                                       initialSpringVelocity: 5, options: [],
                                       animations: {
                                        cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                        },
                                       completion: nil
                        )
        }
        )
        cell.addToSpace.isHidden = false
        cell.addToShoppingList.isHidden = false
        //cell.overlayTimeRemaining(days: daysRemaining)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return //the cell is not visible
        }
        let c = cell as! CollectionCell
        c.addToShoppingList.isHidden = true
        c.addToSpace.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard
            let previousTraitCollection = previousTraitCollection,
            self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass ||
                self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass
            else {
                return
        }
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.collectionView?.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        coordinator.animate(alongsideTransition: { context in
            
        }, completion: { context in
            self.collectionView?.collectionViewLayout.invalidateLayout()
            
            self.collectionView?.visibleCells.forEach { cell in
                guard let _ = cell as? CollectionCell else {
                    return
                }
            }
        })
    }
}

extension FoodCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4.0 - 8,
                      height: collectionView.frame.size.width/4.0 - 8)
    }
}

extension FoodCollectionController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentUser.shared.allShoppingLists.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
        }
        var titleData = "\(row)"
        if pickerView == listPicker {
            let keyAtIndex = currentUser.shared.shoppingListIDs[row]
            let currentListName = currentUser.shared.allShoppingLists[keyAtIndex]?.name
            titleData = currentListName!
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:18.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        
        return pickerLabel!
    }
}


