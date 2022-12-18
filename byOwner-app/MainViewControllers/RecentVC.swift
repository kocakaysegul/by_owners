//
//  RecentVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 5.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ProgressHUD

class RecentVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, PropertyCollectionViewCellDelegate {
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    var numberOfPropertiesTextField : UITextField!
    
    var properties: [Property] = [] // Once we get all our properties from BACKENDLESS, we're gonna put in these variables to an empty array.

    
    override func viewWillLayoutSubviews() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Load properties
        loadProperties(limitNumber: kRECENTPROPERTYLIMIT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    //MARK: CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return properties.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PropertyCollectionViewCell
        cell.delegate = self
        cell.generateCell(property: properties[indexPath.row])
        return cell
    }
    
    
    
    //MARK: CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // show property
        print("222222222222222222222222")
        let propertyView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PropertyView") as! PropertyVC
        propertyView.property = properties[indexPath.row] //this way we're passing exact the same property we create. We're passing to our view here.
        self.present(propertyView, animated: true, completion: nil)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(254))
    }
    
    
    
    //MARK: Load Properties
    func loadProperties(limitNumber: Int) {
        Property.fetchRecentProperties(limitNumber: limitNumber) { (allProperties) in
            if allProperties.count != 0 {
                self.properties = allProperties as! [Property]
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    //MARK: IBActions
    
    @IBAction func mixerButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Update", message: "Set the number of properties to display", preferredStyle: .alert)
        alertController.addTextField { (numberOfProperties) in
            numberOfProperties.placeholder = "Number of Properties"
            numberOfProperties.borderStyle = .roundedRect
            numberOfProperties.keyboardType = .numberPad
            
            self.numberOfPropertiesTextField = numberOfProperties
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            if self.numberOfPropertiesTextField?.text != "" && self.numberOfPropertiesTextField!.text != "0" {
                
                ProgressHUD.show("Updating...")
                self.loadProperties(limitNumber: Int(self.numberOfPropertiesTextField!.text!)!)
                
            }
            ProgressHUD.dismiss()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(updateAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: PropertyCollectionViewCellDelegate
    func didClickStarButton(property: Property) {
        
        //check if we have a user
        if FUser.currentUser() != nil {
            
            let user = FUser.currentUser()!
            
            //check if the property is in favorit
            
            if user.favoritProperties.contains(property.objectId!) {
                //remove from favorit list
                
                let index = user.favoritProperties.index(of: property.objectId!)
                user.favoritProperties.remove(at: index!)
                
                updateCurrentUser(withValues: [kFAVORIT : user.favoritProperties], withBlock: { (success) in
                    
                    if !success {
                        print("error removing favorite")
                    } else {
                        
                        self.collectionView.reloadData()
                        ProgressHUD.showSuccess("Removed from the list")
                    }
                    
                })
                
                
            } else {
                
                //add to favorit list
                user.favoritProperties.append(property.objectId!)
                
                updateCurrentUser(withValues: [kFAVORIT : user.favoritProperties], withBlock: { (success) in
                    
                    if !success {
                        print("error adding property")
                    } else {
                        
                        self.collectionView.reloadData()
                        ProgressHUD.showSuccess("Added to the list")
                    }
                    
                })
                
            }
            
        } else {
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView") as! RegisterVC
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    


}
