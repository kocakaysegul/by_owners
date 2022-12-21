//
//  MyPropertiesVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 13.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ProgressHUD

class MyPropertiesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var properties: [Property] = []
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !isUserLoggedIn(viewController: self) {
            return
        } else {
            loadProperties()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: collectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(property: properties[indexPath.row])
        
        return cell
        
    }
    
    //MARK: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let propertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyVC
        
        propertyVC.property = properties[indexPath.row]
        self.present(propertyVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
    }

    
    //MARK: LoadProperties
    
    func loadProperties() {
        
        let userId = FUser.currentId()
        
        let whereClause = "ownerId = '\(userId)'"
        
        Property.fetchPropertiesWith(whereClause: whereClause) { (allProperties) in
            
            self.properties = allProperties as! [Property]
            self.collectionView.reloadData()
        }
        
    }
    
    //MARK: PropertyCollectionViewCellDelegate
    
    func didClickMenuButton(property: Property) {
        
        let soldStatus = property.isSold ? "Mark Available" : "Mark Sold"
        var topStatus = "Promote"
        var isInTop = false
        
        if property.inTopUntil != nil && property.inTopUntil! > Date() {
            isInTop = true
            topStatus = "Already in top"
        }
        
        //actionsheet
        let optionMenu = UIAlertController(title: "Property Menu", message: nil, preferredStyle: .actionSheet)
        //we have an option menu which is UI alert controller.
        
        let editAction = UIAlertAction(title: "Edit property", style: .default) { (alert) in
            
            let addPropertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPropertyVC") as! AddPropertyVC
            
            addPropertyVC.property = property // for edit
            self.present(addPropertyVC, animated: true, completion: nil)
        }
        
        let makeTop = UIAlertAction(title: topStatus, style: .default) { (action) in
            
            
            let coins = FUser.currentUser()!.coins
            
            if coins >= 10 && !isInTop {
                
                updateCurrentUser(withValues: [kCOINS : coins - 10], withBlock: { (success) in
                    
                    if success {
                        
                        let expDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                        
                        property.inTopUntil = expDate
                        property.saveProperty()
                        self.loadProperties()//refresh
                    }
                })
            } else {
                if isInTop {
                    ProgressHUD.showError("Already in top!")
                } else {
                    ProgressHUD.showError("Insuffucuent coins!")
                }
            }
            
        }
        
        let soldAction = UIAlertAction(title: soldStatus, style: .default) { (action) in
            
            property.isSold = !property.isSold
            property.saveProperty()
            self.loadProperties()//refresh
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            ProgressHUD.show("Deleting...")
            property.deleteProperty(property: property, completion: { (message) in
                
                ProgressHUD.showSuccess("Deleted!")
                self.loadProperties()// refresh
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(makeTop)
        optionMenu.addAction(soldAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
}




