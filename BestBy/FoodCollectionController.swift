import UIKit

private let reuseIdentifier = "Cell"

class FoodCollectionController: UICollectionViewController {
        
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return FoodData.food_data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionCell
        let key = Array(FoodData.food_data.keys)[indexPath.row]
        
        if FoodData.food_data[key] != nil{
            cell.imageView.image = FoodData.food_data[key]!.2
        } else {
            FoodData.food_data[key]!.2 = UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal)
            cell.imageView.image = FoodData.food_data[key]!.2
        }
        cell.foodName.text = key
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionCell
        self.navigationItem.title = cell.foodName.text
        let key = Array(FoodData.food_data.keys)[indexPath.row]
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
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionCell
        cell.removeOverlay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "All Items"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(collectionView!.indexPathsForSelectedItems!.count > 0) {
            let cell = collectionView?.cellForItem(at: (collectionView?.indexPathsForSelectedItems![0])!) as! CollectionCell
            cell.removeOverlay()
        }
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

extension FoodCollectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/4.0 - 8,
                      height: collectionView.frame.size.width/4.0 - 8)
    }
}


