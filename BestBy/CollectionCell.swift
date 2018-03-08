//
//  CollectionCell.swift
//  BestBy
//
//  Created by Abhinav Sangisetti on 3/5/18.
//  Copyright © 2018 Quatro. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.imageView = imageView
        
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor)
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = CGFloat(roundf(Float(self.imageView.frame.size.width/2.0)))
    }
}
