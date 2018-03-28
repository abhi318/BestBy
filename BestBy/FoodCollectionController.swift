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
        cell.layoutSubviews()
        let key = Array(FoodData.food_data.keys)[indexPath.row]
        var m = ""
        var daysRemaining = -1
        if FoodData.food_data[key] != nil {
            m = FoodData.food_data[key]!.1
            daysRemaining = FoodData.food_data[key]!.0
        } else {
            m = "default"
        }
        let old = cell.imageView.frame
        
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
        

//        let imgFrame = cell.imageView.frame
//        let nameFrame = cell.foodName.frame
//
//        let size = CGSize(width: 150, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//
//        let estimatedFrame =  NSString(string: (FoodData.food_data[key]?.1)!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], context: nil)
//
//        var constant:CGFloat = 0.0
//        if ((indexPath.item + 1) % 4 == 0) {
//            constant = -80
//        }
//
//        cell.bubbleView.frame = CGRect(x: frameX, y: cell.frame.maxY, width: cell.frame.width * 2, height: cell.frame.width * 2)
//        cell.textView.frame = CGRect(x: frameX + 10, y: cell.frame.maxY + 2, width: estimatedFrame.width, height: estimatedFrame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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


