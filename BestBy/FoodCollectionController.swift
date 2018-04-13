import UIKit
import FirebaseDatabase

private let reuseIdentifier = "Cell"

class FoodCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var searchBar: UISearchBar!
    var filteredFood = Array(FoodData.food_data.keys)
    var allFood = Array(FoodData.food_data.keys)
    var searchActive : Bool = false
    var foodBeingAdded: String?
    var flag: Bool = false
    var handle: DatabaseHandle!
    
    @IBOutlet var collectionView: UICollectionView!
    
    func observeExtraFoods() {
        let userRef: DatabaseReference = currentUser.shared.userRef!
        let x = currentUser.shared.ID
        handle = userRef.child("ExtraFoods").observe(.childAdded, with: { (snapshot) in
            let extraItemInfo = snapshot.value as! [String : Any]
            FoodData.food_data[snapshot.key] = (extraItemInfo["doe"] as! Int, extraItemInfo["desc"] as! String, UIImage(named: "groceries"))
            self.allFood = Array(FoodData.food_data.keys)
            self.filteredFood = self.allFood
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeExtraFoods()
        flag = false
        self.navigationItem.title = "All Items"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentUser.shared.userRef?.removeObserver(withHandle: handle)
        if(collectionView!.indexPathsForSelectedItems!.count > 0) {
            if let cell = collectionView?.cellForItem(at: (collectionView?.indexPathsForSelectedItems![0])!) {
                let c = cell as! CollectionCell
                c.addToShoppingList.isHidden = true
                c.addToSpace.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filteredFood.count + 1
        }
        else {
            return allFood.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        
        var key:String
        var count: Int
        
        if cell.isSelected {
            cell.addToSpace.isHidden = false
            cell.addToShoppingList.isHidden = false
        }
        else {
            cell.addToSpace.isHidden = true
            cell.addToShoppingList.isHidden = true
        }
        
        if searchActive {
            count = filteredFood.count
            if indexPath.row == count {
                cell.imageView.image = UIImage(named:"add.png")
                let screenSize: CGRect = cell.imageView.bounds
                cell.imageView.frame = CGRect(x: screenSize.width * 0.25, y: screenSize.height * 0.1, width: screenSize.width * 0.8, height: screenSize.height * 0.8)
                cell.foodName.text = "Add New"
                cell.addToSpace.isHidden = true
                cell.addToShoppingList.isHidden = true
                return cell
            }
            key = filteredFood[indexPath.row]
        }
        else {
            count = allFood.count
            if indexPath.row == count {
                cell.imageView.image = UIImage(named:"add.png")
                let screenSize: CGRect = cell.imageView.bounds
                cell.imageView.frame = CGRect(x: screenSize.width * 0.25, y: screenSize.height * 0.1, width: screenSize.width * 0.8, height: screenSize.height * 0.8)
                cell.addToSpace.isHidden = true
                cell.addToShoppingList.isHidden = true
                cell.foodName.text = "Add New"
                return cell
            }
            key = allFood[indexPath.row]
        }
        
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
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                            sender: Any?) -> Bool {
        if identifier == "addNewFood" && flag {
            return true
        }
        if identifier == "addToShoppingList" && currentUser.shared.shoppingListIDs.count > 0 {
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

extension FoodCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4.0 - 8,
                      height: collectionView.frame.size.width/4.0 - 8)
    }
}


