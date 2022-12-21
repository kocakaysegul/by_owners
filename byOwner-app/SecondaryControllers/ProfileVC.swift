//
//  ProfileVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 16.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ImagePicker
import ProgressHUD

class ProfileVC: UIViewController, ImagePickerDelegate {

    

    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! //Avatar ImageView
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var additionalPhoneTF: UITextField!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        updateUI()
    }

    
    
    //MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        let user = FUser.currentUser()!
        let optionMenu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        let accountTypeString = user.isAgent ? "You're Agent" : "Become an Agent"
        
        let accountTypeAction = UIAlertAction(title: accountTypeString, style: .default) { (alert) in
            print("a")
        }
        
        let restorePurchaseAction = UIAlertAction(title: "Restore purchase", style: .default) { (alert) in
            print("b")
        }
        
        let buyCoinsAction = UIAlertAction(title: "Buy Coins", style: .default) { (alert) in
            print("c")
        }
        
        let saveChangesAction = UIAlertAction(title: "Save Changes", style: .default) { (alert) in
            self.saveChanges()
        }
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert) in
        
            FUser.logOutCurrentUser(withBlock: { (success) in
                
                if success {
                    
                    let recentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                    self.present(recentVC, animated: true, completion: nil)
                }
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
          
            
        }
        
        optionMenu.addAction(saveChangesAction)
        optionMenu.addAction(buyCoinsAction)
        optionMenu.addAction(accountTypeAction)
        optionMenu.addAction(restorePurchaseAction)
        optionMenu.addAction(logOutAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func changeAvatarButtonPressed(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //MARK: Helpers
    
    func saveChanges() {
        
        var addPhone = ""
        
        if additionalPhoneTF.text != "" {
            addPhone = additionalPhoneTF.text!
        }
        
        if nameTF.text != "" && surnameTF.text != "" {
            
            ProgressHUD.show("Saving...")
            
            var values = [kFIRSTNAME : nameTF.text!, kLASTNAME : surnameTF.text!, kADDPHONE : addPhone] // saving changes
            
            if avatarImage != nil { // If avatar image is picked
                
                let image = UIImageJPEGRepresentation(avatarImage!, 0.6)
                let avatarSring = image!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                values = [kFIRSTNAME : nameTF.text!, kLASTNAME : surnameTF.text!, kADDPHONE : addPhone, kAVATAR : avatarSring] // // saving changes
            }
            
            updateCurrentUser(withValues: values, withBlock: { (success) in
                
                if !success {
                    ProgressHUD.showError("Couldnt Update User")
                    
                } else {
                    ProgressHUD.showSuccess("Saved!")
                }
            })
            
            
        } else {
            
            ProgressHUD.showError("Name and Surname coont be empty")
        }
        
        
    }
    
    
    
    func updateUI(){
        let mobileImageView = UIImageView(image: UIImage(named: "Mobile"))
        mobileImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        mobileImageView.contentMode = .scaleAspectFit
        
        let mobileImageView1 = UIImageView(image: UIImage(named: "Mobile"))
        mobileImageView1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        mobileImageView1.contentMode = .scaleAspectFit
        
        let contactImageView = UIImageView(image: UIImage(named: "ContactLogo"))
        contactImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        contactImageView.contentMode = .scaleAspectFit
        
        let contactImageView1 = UIImageView(image: UIImage(named: "ContactLogo"))
        contactImageView1.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        contactImageView1.contentMode = .scaleAspectFit
        
        nameTF.leftViewMode = .always
        nameTF.leftView = contactImageView
        nameTF.addSubview(contactImageView)
        
        surnameTF.leftViewMode = .always
        surnameTF.leftView = contactImageView1
        surnameTF.addSubview(contactImageView1)
        
        mobileTF.leftViewMode = .always
        mobileTF.leftView = mobileImageView
        mobileTF.addSubview(mobileImageView)
        
        additionalPhoneTF.leftViewMode = .always
        additionalPhoneTF.leftView = mobileImageView1
        additionalPhoneTF.addSubview(mobileImageView1)
        
        let user = FUser.currentUser()!
        
        nameTF.text = user.firstName
        surnameTF.text = user.lastName
        mobileTF.text = user.phoneNumber
        additionalPhoneTF.text = user.additionalPhoneNumber
        coinsLabel.text = "\(user.coins)"
        
        if user.avatar != "" { // We have an image
            imageFromData(pictureData: user.avatar, withBlock: { (image) in

                self.imageView.image = image!.circleMasked
            })
        }
        
    }
    
    
    //MARK: UIImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        avatarImage = images.first
        imageView.image = avatarImage!.circleMasked
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
