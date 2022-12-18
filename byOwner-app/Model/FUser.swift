//
//  FUser.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 22.10.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import Foundation
import Firebase

class FUser {
    
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var coins: Int
    var company: String
    var firstName: String
    var lastName: String
    var fullName: String
    var avatar: String
    var phoneNumber: String
    var additionalPhoneNumber: String
    var isAgent: Bool
    var favoritProperties: [String]
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _firstName: String, _lastName: String, _avatar: String = "", _phoneNumber: String = "") {
        
        objectId = _objectId
        pushId = _pushId
        
        createdAt = _createdAt
        updatedAt = _updatedAt
        
        coins = 10
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        avatar = _avatar
        isAgent = false
        company = ""
        favoritProperties = []
        
        phoneNumber = _phoneNumber
        additionalPhoneNumber = ""
    }

    // User initialiser
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        if let created = _dictionary[kCREATEDAT] {
            createdAt = dateFormatter().date(from: created as! String)!
        } else {
            createdAt = Date()
        }
        if let updated = _dictionary[kUPDATEDAT] {
            updatedAt = dateFormatter().date(from: updated as! String)!
        } else {
            updatedAt = Date()
        }
        
        if let dcoin = _dictionary[kCOINS] {
            coins = dcoin as! Int
        } else {
            coins = 0
        }
        if let comp = _dictionary[kCOMPANY] {
            company = comp as! String
        } else {
            company = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        fullName = firstName + " " + lastName
        if let avat = _dictionary[kAVATAR] {
            avatar = avat as! String
        } else {
            avatar = ""
        }
        if let agent = _dictionary[kISAGENT] {
            isAgent = agent as! Bool
        } else {
            isAgent = false
        }
        if let phone = _dictionary[kPHONE] {
            phoneNumber = phone as! String
        } else {
            phoneNumber = ""
        }
        if let addphone = _dictionary[kADDPHONE] {
            additionalPhoneNumber = addphone as! String
        } else {
            additionalPhoneNumber = ""
        }
        if let favProp = _dictionary[kFAVORIT] {
            favoritProperties = favProp as! [String]
        } else {
            favoritProperties = []
        }
    }
    
    class func currentId() -> String {  // This func returns the ID of our current user which is logged in on the device.
        
        return Auth.auth().currentUser!.uid  //we're accessing our firebase authentication and getting the current user ID
    }
    
    class func currentUser() -> FUser? { // It returns our current logged in user who registered on the device. We used "?" bcz if we don't have a current user who registered on the device it will be needed. Otherwise our app may crash.
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER){ // if we have user
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        return nil
    }
    
    class func registerUserWith(email: String, password: String, firstName: String, lastName: String, completion: @escaping (_ error: Error?)-> Void) { // Firebase takes all these informations and registers
        Auth.auth().createUser (withEmail: email, password: password) { (firUser, error) in
            if error != nil {
                completion(error)
                return
            }
            let fUser = FUser(_objectId: firUser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _firstName: firstName, _lastName: lastName)
            
            //save to user defaults
            saveUserLocally(fUser: fUser)
            //save user to firebase
            saveUserInBackground(fUser: fUser)
            
            
            completion(error)
        }
    }
    
    class func registerUserWith(phoneNumber: String, verificationCode: String, completion: @escaping (_ error: Error?, _ shouldLogin: Bool) -> Void) {
        let verificationID = UserDefaults.standard.value(forKey: kVERIFICATIONCODE)
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID as! String, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credentials) { (firUser, error) in
            if error != nil {
                completion(error!, false)
                return
            }
            // check if user is logged in else register
            fetchUserWith(userId: firUser!.uid, completion: { (user) in
                if user != nil && user!.firstName != "" {
                    // We have a user, login
                    saveUserLocally(fUser: user!)
                    completion(error, true)
                } else {
                    // We have no user, register user
                    let fUser = FUser(_objectId: firUser!.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _firstName: "", _lastName: "", _phoneNumber: firUser!.phoneNumber!)
                    saveUserLocally(fUser: fUser)
                    saveUserInBackground(fUser: fUser)
                    completion(error, false)
                }
            })
        }
    }
    
}

//MARK: Saving User

func saveUserInBackground(fUser: FUser) {
    let ref = firebase.child(kUSER).child(fUser.objectId)
    ref.setValue(userDictionaryFrom(user: fUser))
}

func saveUserLocally(fUser: FUser) { // We are creating a function that we do register save our user to user defaults.
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize() // Our user is saved in background.
}




//MARK: Helper functions

func fetchUserWith(userId: String, completion: @escaping (_ user: FUser?) -> Void) {
    // This func will check our firebase to find the user with specific ID; user ID.
    
    firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: userId).observeSingleEvent(of: .value) { (snapshot) in
        if snapshot.exists() {
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary
            let user = FUser(_dictionary: userDictionary)
            completion(user)
        } else {
            completion(nil)
        }
    }
}

// We need a function that converts FUser to NSDictionary
func userDictionaryFrom(user: FUser) -> NSDictionary { // We can use this function now to save to user defaults
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    // So these are all the values of our user that we want to save.
    return NSDictionary(objects: [user.objectId, createdAt, updatedAt, user.company, user.pushId!, user.firstName, user.lastName, user.fullName, user.avatar, user.phoneNumber, user.additionalPhoneNumber, user.isAgent, user.coins, user.favoritProperties], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kCOMPANY as NSCopying, kPUSHID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kPHONE as NSCopying, kADDPHONE as NSCopying, kISAGENT as NSCopying, kCOINS as NSCopying, kFAVORIT as NSCopying])
    
}
