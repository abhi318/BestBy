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
        label.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        label.layer.cornerRadius = 10
        label.text = "none"
        return label
    }()
    
    var currentlySelected = false
    
    var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        //view.frame = CGRect(x: 10, y: 0, width: 70, height: 70)
        return view
    }()
    
    var textView: UILabel = {
        let label = UILabel()
        label.textColor = gradient[0]
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 20
        label.lineBreakMode = .byWordWrapping
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        //label.frame = CGRect(x: 20, y: 0, width: 50, height: 50)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func overlayTimeRemaining(days: Int) {
        if days == -1 {
            timeRemaining.text = String("∞")
        }
        else {
            timeRemaining.text = String("\(days)")
        }
    }
        
        
//        let size = CGSize(width: 150, height: 1000)
//        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//
//        let estimatedFrame =  NSString(string: message).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], context: nil)
//
//        var constant:CGFloat = 0.0
//        if ((idx + 1) % 4 == 0) {
//            constant = -80
//        }
//
//        self.textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constant + 13).isActive = true
//        self.textView.widthAnchor.constraint(equalToConstant: self.frame.width * 2 - 16).isActive = true
//        self.textView.heightAnchor.constraint(equalToConstant: estimatedFrame.height).isActive = true
//        self.textView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: CGFloat(13)).isActive = true
//
//        self.bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constant + 5).isActive = true
//        self.bubbleView.widthAnchor.constraint(equalToConstant: self.frame.width * 2).isActive = true
//        self.bubbleView.heightAnchor.constraint(equalToConstant: estimatedFrame.height + 16).isActive = true
//        self.bubbleView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 5).isActive = true
//
//        let x = textView.frame
//        let y = bubbleView.frame
//
//                bubbleView.frame = CGRect(x: frameX, y: cell.frame.maxY, width: cell.frame.width * 2, height: cell.frame.width * 2)
//                textView.frame = CGRect(x: frameX + 10, y: cell.frame.maxY + 2, width: estimatedFrame.width, height: estimatedFrame.height)
}
