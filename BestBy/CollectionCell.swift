//
//  CollectionCell.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/5/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    
    var timeRemaining: UILabel =  {
        let label = UILabel()
        label.isHidden = true
        return label
    }()
    
    var currentlySelected = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func overlayTimeRemaining(days: Int) {
        timeRemaining.frame = CGRect(x: 0, y: 0, width: self.frame.width * 1.1, height: self.frame.height * 1.1)
        timeRemaining.layer.cornerRadius = 10
        var ratio = (CGFloat(days)/14.0)
        
        if ratio > 1 {
            ratio = 1
        }
        
        //timeRemaining.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.2)
        timeRemaining.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)

        timeRemaining.isHidden = false
        timeRemaining.clipsToBounds = true
        self.addSubview(timeRemaining)
    }
    
    func removeOverlay() {
        timeRemaining.isHidden = true
    }
}
