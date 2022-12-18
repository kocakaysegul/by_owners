//
//  FavoriteVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 12.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ProgressHUD

class FavoriteVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {

    @IBOutlet weak var noPropertyLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var properties : [Property] = []
    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //this will prevent loadProperties() function to be called if our user is not logged in
        
        if !isUserLoggedIn(viewController: self) { // if not
            return
        } else {
            loadProperties() // if user is logged in
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    //Mark: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        cell.delegate = self
        cell.generateCell(property: properties[indexPath.row])
        return cell
    }
    
    //Mark: CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let propertyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyVC
        propertyVC.property = properties[indexPath.row]
        self.present(propertyVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
    }
    
    //Mark: LoadProperties
    
    func loadProperties() {
        
        self.properties = []
        
        let user = FUser.currentUser()!
        
        let stringArray = user.favoritProperties // This is a array of our object. One user can have multiple favorite property. :)))
        let string = "'" + stringArray.joined(separator: "', '") + "'" // Our favorite objects
        print("special string \(string)")
        
        if user.favoritProperties.count > 0 {
            
            let whereClause = "objectId IN (\(string))" // Dataservice API -> Backendless Dokumentation
            
            Property.fetchPropertiesWith(whereClause: whereClause, completion: { (allProperties) in
                
                if allProperties.count != 0 {
                    self.properties = allProperties as! [Property]
                    self.collectionView.reloadData() // we need to refresh
                }
                
            })
            
        } else {
            self.noPropertyLabel.isHidden = false
            self.collectionView.reloadData() // When user remove the favorite property or add, we need to refresh. :)
        }
        
    }
    
    //MARK: PropertyCollectionViewCellDelegate
    
    func didClickStarButton(property: Property) { // If we touch the star button what will happen
        
        if FUser.currentUser() != nil { // if we have a user
            
            let user = FUser.currentUser()!
            
            if user.favoritProperties.contains(property.objectId!) { // if the property is favorite property
                
                //remove from the list
                let index = user.favoritProperties.index(of: property.objectId!)
                user.favoritProperties.remove(at: index!) //we are removing the favorite specific property from our array.
                
                updateCurrentUser(withValues: [kFAVORIT : user.favoritProperties], withBlock: { (success) in
                    
                    if !success {
                        print("error removing property")
                    } else {
                        self.loadProperties()
                        ProgressHUD.showSuccess("Removed from list")
                    }
                })
                
            } else {
                //add to the list
                user.favoritProperties.append(property.objectId!)
                updateCurrentUser(withValues: [kFAVORIT : user.favoritProperties], withBlock: { (success) in
                    
                    if !success {
                        print("error adding property")
                    } else {
                        self.loadProperties()
                        ProgressHUD.showSuccess("Added to the list")
                    }
                })
            }
            
            
            //we have a user
        } else {
            //no current user
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView") as! RegisterVC
            
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    

    
    
}
