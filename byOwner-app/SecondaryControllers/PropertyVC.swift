//
//  PropertyVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 11.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import MapKit
import IDMPhotoBrowser

class PropertyVC: UIViewController {

    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shortInformationLabel: UILabel!
    @IBOutlet weak var propertyTypeLabel: UILabel!
    @IBOutlet weak var titleDeedsLabel: UILabel!
    @IBOutlet weak var centralHeatingLabel: UILabel!
    @IBOutlet weak var solarWaterHeatingLabel: UILabel!
    @IBOutlet weak var airConditionLabel: UILabel!
    @IBOutlet weak var storeRoomLabel: UILabel!
    @IBOutlet weak var furnishedLabel: UILabel!
    @IBOutlet weak var balconySizeLabel: UILabel!
    @IBOutlet weak var bathroomsLabel: UILabel!
    @IBOutlet weak var parkingLabel: UILabel!
    @IBOutlet weak var FloorLabel: UILabel!
    @IBOutlet weak var constructionYearLabel: UILabel!
    @IBOutlet weak var avaliableDateLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var callBackButtonOutlet: UIButton!
    
    
    var property: Property!
    var propertyCoordinate: CLLocationCoordinate2D?
    var tapGesture: UIGestureRecognizer!
    
    
    var imageArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPropertyImages()
        setupUI()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageScrollView.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: 955)
        
    }
    
    
    //MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func callBackButtonPressed(_ sender: Any) {
    }
    
    
    //MARK: Helpers
    
    @objc func imageTapped() {
        
        let photos = IDMPhoto.photos(withImages: imageArray)
        let browser = IDMPhotoBrowser(photos: photos)!
        browser.setInitialPageIndex(0)
        
        self.present(browser, animated: true, completion: nil)
    }
    
    func getPropertyImages() {
        if property.imageLinks != "" && property.imageLinks != nil {
            downloadImages(urls: property.imageLinks!, withBlock:  { (images) in
                self.imageArray = images as! [UIImage]
                self.setSlideShow()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            })
        } else {
            // we have no images
            self.imageArray.append(UIImage(named: "propertyPlaceholder")!)
            self.setSlideShow()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    func setSlideShow() {
        for i in 0..<imageArray.count {
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleAspectFit
            
            let xPos = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPos, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
            
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1) // it's gonna be dynamic
            imageScrollView.addSubview(imageView)
        }
    }
    
    func setupUI() {
        
        if FUser.currentUser() != nil {
            self.callBackButtonOutlet.isEnabled = true
        }
        
        //set properties
        
        titleLabel.text = property.title!
        priceLabel.text = "\(property.price)"
        shortInformationLabel.text = "\(property.size) m² - \(property.numberOfRooms) Bedroom(s)"
        propertyTypeLabel.text = property.propertyType
        furnishedLabel.text = property.isFurnished ? "YES" : "NO"
        storeRoomLabel.text = property.storeRoom ? "YES" : "NO"
        airConditionLabel.text = property.airConditioner ? "YES" : "NO"
        solarWaterHeatingLabel.text = property.solarWaterHeating ? "YES" : "NO"
        centralHeatingLabel.text = property.centralHeating ? "YES" : "NO"
        titleDeedsLabel.text = property.titleDeeds ? "YES" : "NO"
        constructionYearLabel.text = property.buildYear
        FloorLabel.text = "\(property.floor)"
        parkingLabel.text = "\(property.parking)"
        bathroomsLabel.text = "\(property.numberOfBathrooms)"
        balconySizeLabel.text = "\(property.balconySize)"
        avaliableDateLabel.text = property.availableFrom
        
        //optional
        descriptionLabel.isHidden = true
        descriptionTextField.isHidden = true
        addressLabel.isHidden = true
        mapView.isHidden = true
        
        if property.propertyDescription != nil {
            descriptionLabel.isHidden = false
            descriptionTextField.isHidden = false
            descriptionTextField.text = property.propertyDescription
        }
        
        if property.address != nil && property.address != "" {
            addressLabel.isHidden = false
            addressLabel.text = property.address
        }
        
        if property.latitude != 0 && property.latitude != nil {
            
            mapView.isHidden = false
            
            propertyCoordinate = CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)
            
            let annotation = MKPointAnnotation()
            
            annotation.title = property.title
            annotation.subtitle = "\(property.numberOfRooms) bedroom \(property.propertyType!)"
            annotation.coordinate = propertyCoordinate!
            self.mapView.addAnnotation(annotation)
        }
        
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: stackView.frame.size.height + 50)
        
    }
    
}
