import UIKit

private let reuseIdentifier = "Cell"

class FoodCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchControllerDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    var filteredFood = Array(FoodData.food_data.keys)
    var searchActive : Bool = false
    var foodBeingAdded: String?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Foods"
        searchController.searchBar.delegate = self

        searchController.searchBar.returnKeyType = (UIReturnKeyType.done)

        searchController.searchBar.becomeFirstResponder()
        navigationItem.searchController = searchController

        filteredFood = Array(FoodData.food_data.keys)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationItem.title = "All Items"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(collectionView!.indexPathsForSelectedItems!.count > 0) {
            if let cell = collectionView?.cellForItem(at: (collectionView?.indexPathsForSelectedItems![0])!) {
                let c = cell as! CollectionCell
                c.removeOverlay()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filteredFood.count
        }
        else
        {
            return FoodData.food_data.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        
        let key = filteredFood[indexPath.row]
        
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
        self.navigationItem.title = cell.foodName.text
        let key = filteredFood[indexPath.row]
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
        
        cell.overlayTimeRemaining(days: daysRemaining)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionCell
        cell.removeOverlay()
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView()
        
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
        if identifier == "profile" {
            return true
        }
        if identifier == "addFoodToList" {
            if currentUser.shared.allShoppingLists.count == 0 {
                if self.navigationController?.parent is MainViewController {
                    let tabbar = self.navigationController?.parent as! UITabBarController
                    tabbar.selectedIndex = 1
                }
                return false
            }
        }
        if self.navigationItem.title == "All Items" || self.navigationItem.title == nil {
            return false
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFoodToSpace" {
            if let destinationVC = segue.destination as? AddFoodToSpaceViewController {
                let key = self.navigationItem.title
                destinationVC.selected_food = key
            }
        }
        if segue.identifier == "addFoodToList" {
            if let destinationVC = segue.destination as? AddFoodToListFromCollectionViewController {
                let key = self.navigationItem.title
                destinationVC.selected_food = key
            }
        }
    }

}


extension FoodCollectionController: UISearchBarDelegate, UISearchResultsUpdating {
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let all_food_names = Array(FoodData.food_data.keys)
        filteredFood = all_food_names.filter({( food_name : String) -> Bool in
            return food_name.lowercased().contains((searchController.searchBar.text!).lowercased())
        })
        
        self.collectionView!.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView!.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView!.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredFood = Array(FoodData.food_data.keys)
        searchController.searchBar.resignFirstResponder()
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


