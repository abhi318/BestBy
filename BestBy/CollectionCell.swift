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
        /*if days < 0 {
            timeRemaining.attributedText = NSAttributedString(string: infinity, attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        }
        else {
            timeRemaining.attributedText =  NSAttributedString(string: "\(days)", attributes: [NSAttributedStringKey.font:UIFont(name: "Futura-Medium", size:20.0)!,NSAttributedStringKey.foregroundColor:UIColor.black])
        }*/
        //timeRemaining.textAlignment = .center
        timeRemaining.frame = CGRect(x: 0, y: 0, width: self.frame.width * 1.1, height: self.frame.height * 1.1)
        timeRemaining.layer.cornerRadius = 10
        var ratio = (CGFloat(days)/30.0)
        
        if ratio > 1 {
            ratio = 1
        }
        
        timeRemaining.backgroundColor = UIColor(hue: ratio/3, saturation: 1.0, brightness: 1.0, alpha: 0.2)

        timeRemaining.isHidden = !timeRemaining.isHidden
        timeRemaining.clipsToBounds = true
        self.addSubview(timeRemaining)
    }
    
    func removeOverlay() {
        timeRemaining.isHidden = true
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
