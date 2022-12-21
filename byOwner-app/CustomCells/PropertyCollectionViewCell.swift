//
//  PropertyCollectionViewCell.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 5.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit

@objc protocol PropertyCollectionViewCellDelegate { // for star button
    @objc optional func didClickStarButton(property: Property)
    @objc optional func didClickMenuButton(property: Property)
}

class PropertyCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var soldImageView: UIImageView!
    @IBOutlet weak var topAdImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var bathroomLabel: UILabel!
    @IBOutlet weak var parkingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var delegate: PropertyCollectionViewCellDelegate? // Protocol
    
    var property : Property!
    
    func generateCell(property: Property) {
        
        self.property = property
        
        titleLabel.text = property.title
        roomLabel.text = "\(property.numberOfRooms)"
        bathroomLabel.text = "\(property.numberOfBathrooms)"
        parkingLabel.text = "\(property.parking)"
        
        priceLabel.text = "\(property.price)"
        priceLabel.sizeToFit()
        
        //top ad
        if property.inTopUntil != nil && property.inTopUntil! > Date() {
            topAdImageView.isHidden = false
        } else {
            topAdImageView.isHidden = true
        }
        
        // like property
        if self.likeButtonOutlet != nil {
            if FUser.currentUser() != nil && FUser.currentUser()!.favoritProperties.contains(property.objectId!) {
                self.likeButtonOutlet.setImage(UIImage(named: "starFilled"), for: .normal)
            } else {
                self.likeButtonOutlet.setImage(UIImage(named: "star"), for: .normal)
            }
        }
        
        //sold
        if property.isSold {
            soldImageView.isHidden = false
        } else {
            soldImageView.isHidden = true
        }
        
        //image
        if property.imageLinks != "" && property.imageLinks != nil {
            //download images
            downloadImages(urls: property.imageLinks!, withBlock: { (images) in
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                self.imageView.image =  images.first!
            })
        } else {
            self.imageView.image = UIImage(named: "propertyPlaceholder")
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
        }
        
        
    }
    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate!.didClickMenuButton!(property: property)
    }
    
    @IBAction func starButtonPressed(_ sender: Any) {
        delegate!.didClickStarButton!(property: property)
        
    }
    
}
