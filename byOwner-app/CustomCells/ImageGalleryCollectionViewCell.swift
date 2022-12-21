//
//  ImageGalleryCollectionViewCell.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 14.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit

protocol ImageGalleryCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var indexPath: IndexPath!
    var delegate: ImageGalleryCollectionViewCellDelegate?
    
    func generateCell(image: UIImage, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.imageView.image = image
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.didClickDeleteButton(indexPath: self.indexPath)
    }
}
