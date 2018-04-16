//
//  SpacesLayout.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/21/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class SpacesLayout: UICollectionViewLayout {

    // MARK: Properties and Variables
    
    /* The amount the user needs to scroll before the featured cell changes */
    let dragOffset: CGFloat = 90
    var old = -1
    var cache = [UICollectionViewLayoutAttributes]()
    
    /* Returns the item index of the currently featured cell */
    var featuredItemIndex: Int {
        get {
            /* Use max to make sure the featureItemIndex is never < 0 */
            return max(0, Int(collectionView!.contentOffset.y / dragOffset))
        }
    }
    
    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    var nextItemPercentageOffset: CGFloat {
        get {
            return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
    
    /* Returns the width of the collection view */
    var width: CGFloat {
        get {
            return (collectionView!.bounds).width
        }
    }
    
    /* Returns the height of the collection view */
    var height: CGFloat {
        get {
            return (collectionView!.bounds).height
        }
    }
    
    /* Returns the number of items in the collection view */
    var numberOfItems: Int {
        get {
            return collectionView!.numberOfItems(inSection: 0)
        }
    }
    
    // MARK: UICollectionViewLayout
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.alpha = 0
        attributes?.transform = CGAffineTransform(
            translationX: 0,
            y: 100
        )
        
        return attributes
    }
    
    /* Return the size of all the content in the collection view */
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.alpha = 0
        attributes?.transform = CGAffineTransform(
            translationX: -400,
            y: 0
        )

        return attributes
    }
    
    override var collectionViewContentSize : CGSize {
        let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        
        let standardHeight: CGFloat = 45
        let featuredHeight: CGFloat = 150
        
        var frame = CGRect()
        var y: CGFloat = 0
        if featuredItemIndex != old {
            //let strrrr = "idx:  \(featuredItemIndex)"
            old = featuredItemIndex
        }
        for item in 0..<numberOfItems {
            // 1
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 2
            attributes.zIndex = item
            var height = standardHeight
            
            // 3
            if indexPath.item == featuredItemIndex {
                // 4
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView!.contentOffset.y - yOffset
                height = featuredHeight
            } else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
                let maxY = standardHeight + y
                height = standardHeight + max((featuredHeight-standardHeight) * nextItemPercentageOffset, 0)
                y = maxY - height
            }
            
            // 6
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = (frame).maxY
        }
    }
    
    /* Return all attributes in the cache whose frame intersects with the rect passed to the method */

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayout(forBoundsChange: CGRect) -> Bool {
        return true
    }
    
}
