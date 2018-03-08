////
////  FoodListCollectionViewController.swift
////  BestBy
////
////  Created by Abhinav Sangisetti on 3/5/18.
////  Copyright © 2018 Quatro. All rights reserved.
////
//
//import UIKit
//
//private let reuseIdentifier = "Cell"
//
//class FoodListCollectionViewController: UICollectionViewController {
//
//    class ViewController: UICollectionViewController {
//        
//    override func collectionView(_ collectionView: UICollectionView,
//                                 numberOfItemsInSection section: Int) -> Int {
//        return 20
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView,
//                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
//        
//        cell.imageView.image = UIImage(named: "BestByLogoTwitter.png")
//        cell.imageView.backgroundColor = .lightGray
//        
//        return cell
//    }
//    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        guard
//            let previousTraitCollection = previousTraitCollection,
//            self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass ||
//                self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass
//            else {
//                return
//        }
//        
//        self.collectionView?.collectionViewLayout.invalidateLayout()
//        self.collectionView?.reloadData()
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
//        self.collectionView?.collectionViewLayout.invalidateLayout()
//        
//        coordinator.animate(alongsideTransition: { context in
//            
//        }, completion: { context in
//            self.collectionView?.collectionViewLayout.invalidateLayout()
//            
//            self.collectionView?.visibleCells.forEach { cell in
//                guard let cell = cell as? CollectionCell else {
//                    return
//                }
//            }
//        })
//    }
//}
//
//extension FoodListCollectionViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        return CGSize(width: collectionView.frame.size.width/3.0 - 8,
//                      height: collectionView.frame.size.width/3.0 - 8)
//    }
//}

