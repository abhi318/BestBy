//
//  SpacesCell.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/22/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import Foundation
import UIKit

class SpacesCell : UICollectionViewCell{
    
    @IBOutlet weak var listName:UILabel?
    @IBOutlet weak var collectionOfFoods:UICollectionView?
    
    var listID: String?
    var currentList:FoodList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionOfFoods?.dataSource = self
        self.collectionOfFoods?.delegate = self
        self.collectionOfFoods?.isScrollEnabled = false
    }
    
}

extension SpacesCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(currentList == nil) {
            index
            return 0
        }
        return ((currentList!.contents.count < 18) ? currentList!.contents.count : 18)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCell", for: indexPath) as! FoodPreviewCell
        
        if collectionView == collectionOfFoods {
            if (FoodData.food_data[((currentList?.contents[indexPath.item])?.name)!] == nil) {
                cell.img.image = UIImage(named: "groceries")?.withRenderingMode(.alwaysOriginal)
            } else {
                cell.img.image = FoodData.food_data[((currentList?.contents[indexPath.item])?.name)!]!.2
            }
            
            let foodItem = currentList?.contents[indexPath.item]
            
            let daysLeft = ((foodItem?.timestamp)! - Int(Date().timeIntervalSinceReferenceDate)) / 86400
            
            var ratio = (CGFloat(daysLeft)/40.0)
            if ratio > 1 {
                ratio = 1
            }
            
            cell.backgroundColor = UIColor(named:"white")
            self.bringSubview(toFront: cell)
            cell.ratio = ratio
        }
        
        return cell
    }
    
}

class FoodPreviewCell : UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    
    var overlay:UIView?
    var ratio: CGFloat = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        overlay?.layer.cornerRadius = CGFloat(roundf(Float((overlay?.frame.size.width)! / 2.0)))
        self.addSubview(overlay!)
        self.bringSubview(toFront: img)
        self.sendSubview(toBack: overlay!)
        self.backgroundColor = UIColor(named:"white")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlay?.backgroundColor = UIColor(hue: ratio/3, saturation: 0.5, brightness: 1.0, alpha: 1.0)
    }
    
}
