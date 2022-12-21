//
//  ImageGalleryVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 14.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ImagePicker
import IDMPhotoBrowser

protocol ImageGalleryViewControllerDelegate {
    func didFinishEditingImages(allImages: [UIImage])
}

class ImageGalleryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ImageGalleryCollectionViewCellDelegate, ImagePickerDelegate {

    

    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var allImages : [UIImage] = []
    var property : Property?
    
    var delegate: ImageGalleryViewControllerDelegate? // İf we wrote proptocol we need to initialize delegate to use protocol.
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if property != nil {
            getPropertyImages(property: property!)
        }
        
    }

    
    //CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageGalleryCollectionViewCell
        cell.generateCell(image: allImages[indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //image gallery did select image to show bigger image
        let photos = IDMPhoto.photos(withImages: allImages)
        let browser = IDMPhotoBrowser(photos: photos)!
        browser.setInitialPageIndex(UInt(indexPath.row))
        
        self.present(browser, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width / 2 - 7, height: CGFloat(115))
    }
    
    
    //MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        delegate!.didFinishEditingImages(allImages: allImages)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self as! ImagePickerDelegate
        imagePickerController.imageLimit = kMAXIMAGENUMBER

        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    
    
    //MARK: ImageGalleryCollectionViewCellDelegate
    
    func didClickDeleteButton(indexPath: IndexPath) { // for deleting selected images! :))))
        allImages.remove(at: indexPath.row)
        collectionView.reloadData()
        print("detele clicked")
    }
    
    //MARK : Helpers
    
    func getPropertyImages(property: Property) {
        if property.imageLinks != "" && property.imageLinks != nil {
            //we have images
            
            downloadImages(urls: property.imageLinks!, withBlock:  { (images) in
                self.allImages = images as! [UIImage]
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.collectionView.reloadData()
            })
        } else {
            //we have no images
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.collectionView.reloadData() // refresh
        }
    }
    
    
    //MARK: ImagePickerDelegates
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done pressed \(images.count)")
        self.allImages = allImages + images
        self.collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelled")
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
