//
//  Property.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 5.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import Foundation


@objcMembers  // for backendless
class Property: NSObject {
    
    //Property variables
    var objectId : String?
    var referenceCode: String?
    var ownerId: String?
    var title: String?
    var numberOfRooms: Int = 0
    var numberOfBathrooms: Int = 0
    var size: Double = 0.0
    var balconySize: Double = 0.0
    var parking: Int = 0
    var floor: Int = 0
    var address: String?
    var city: String?
    var country: String?
    var propertyDescription: String?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var advertismentType: String?
    var availableFrom: String?
    var imageLinks: String? //should be text in the backendless, string is too short
    var buildYear: String?
    var price: Int = 0
    var propertyType: String?
    var titleDeeds: Bool = false
    var centralHeating: Bool = false
    var solarWaterHeating: Bool = false
    var airConditioner: Bool = false
    var storeRoom: Bool = false
    var isFurnished: Bool = false
    var isSold: Bool = false
    var inTopUntil: Date?
    
    
    /*
     we want to be able to save a property to backendless
     we want to delete a property to backendless
     we want to retrieve a property to backendless
     we want to be able to edit property to backendless
     */
    
    
    //MARK: Save Functions

    func saveProperty() { // Our property will be saved in backendless
        let dataStore = backendless!.data.of(Property().ofClass()) // We want to save in backendless datastore something one of our properties. Which'll automatically create the table for us.
        dataStore!.save(self) // "self" means our Property
    }
    
    
    
    // This func will save a property and it has a callback function.
    func saveProperty(completion: @escaping (_ value: String)-> Void) {
        let dataStore = backendless!.data.of(Property().ofClass()) // We're accesing our data store
        
        dataStore!.save(self, response: { (result) in // If everything is successful this code will be running.
            completion("Success")
            
        }) { (fault : Fault?) in // This is how backendless called error.
            completion(fault!.message)
        }
    }
    
    
    
    //MARK: Delete functions
    func deleteProperty(property: Property) {
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.remove(property)
    }
    
    
    // In case we want some information about what happened, we use completion handler.
    func deleteProperty(property: Property, completion: @escaping (_ value: String)-> Void){
        
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.remove(property, response: { (result) in
            completion("Success")
            
        }) { (fault : Fault?) in
            
            completion(fault!.message)
        }
    }
    
    //MARK: Search Functions
    /*
     We are going to have 3 different search function. One for showing our recents. Other one is for showing our search and we can use also for our specific property or we want to get old property.
     */
    
    class func fetchRecentProperties(limitNumber: Int, completion: @escaping (_ properties: [Property?])->Void) { // We may have no properties so this is optional(?). This(limitNumber) will return how many properties we want
        
        let quiryBuilder = DataQueryBuilder()
        quiryBuilder!.setSortBy(["inTopUntil DESC"])
        quiryBuilder!.setPageSize(Int32(limitNumber)) // How many object we want to get
        quiryBuilder!.setOffset(0)
        
        let dataStore = backendless!.data.of(Property().ofClass())
        
        dataStore!.find(quiryBuilder, response: { (backendlessProperties) in // response is gonna be our properties that we receive
            
            completion(backendlessProperties as! [Property])   //this is an array of properties why we are sure that this is an array of properties because we are accessing our property table and we are saving properties in our property table.
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([])
        }
    }
    
    
    
    class func fetchAllProperties(completion: @escaping (_ properties: [Property?])->Void) { // This func will return all the properties.
        
        let dataStore = backendless!.data.of(Property().ofClass())
        dataStore!.find({ (allProperties) in
            
            completion(allProperties as! [Property]) //we are returning all the properties we received from backendless
            
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([])
        }
    }
    
    
    // This is going to be used for our searching.
    class func fetchPropertiesWith(whereClause: String, completion: @escaping (_ properties: [Property?])->Void) {
        
        let quiryBuilder = DataQueryBuilder()
        quiryBuilder!.setWhereClause(whereClause) // We want to tell the backendless what we want to search.
        quiryBuilder!.setSortBy(["inTopUntil DESC"]) // And this is how we are going to sort it
        
        let dataStore = backendless!.data.of(Property().ofClass())
        
        dataStore!.find(quiryBuilder, response: { (allProperties) in
            
            completion(allProperties as! [Property])
            
        }) { (fault : Fault?) in
            print("Error, couldnt get recent properties \(fault!.message)")
            completion([]) // Empty array
        }
        
    }
    
} // end of class


func canUserPostProperty(completion: @escaping (_ canPost: Bool)->Void) {
    
    let queryBuilder = DataQueryBuilder()
    let whereClause = "ownerId = '\(FUser.currentId())'"
    queryBuilder!.setWhereClause(whereClause)
    
    let dataStore = backendless!.data.of(Property().ofClass())
    
    dataStore!.find(queryBuilder, response: { (allProperties) in
        
        allProperties!.count == 0 ? completion(true) : completion(false)
        
        
    }) { (fault : Fault?) in
        print("faulr where clause \(fault!.message)")
        completion(true)
    }
}




