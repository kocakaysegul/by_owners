//
//  AddPropertyVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 6.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class AddPropertyVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MapViewDelegate, CLLocationManagerDelegate, ImagePickerDelegate {

    var yearArray: [Int] = []
    
    var datePicker = UIDatePicker()
    var propertyTypePicker = UIPickerView()
    var advertisementTypePicker = UIPickerView()
    var yearPicker = UIPickerView()
    
    var locationManager: CLLocationManager?
    var locationCoordinates: CLLocationCoordinate2D?
    
    var activeField: UITextField?

    //Outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
     //Text Fields
    @IBOutlet weak var referenceCodeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var roomsTextField: UITextField!
    @IBOutlet weak var bathroomsTextField: UITextField!
    @IBOutlet weak var propertySizeTextField: UITextField!
    @IBOutlet weak var balconySizeTextField: UITextField!
    @IBOutlet weak var parkingTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var advertisementTypeTextField: UITextField!
    @IBOutlet weak var avaliableFromTextField: UITextField!
    @IBOutlet weak var buildYearTextField: UITextField!
    @IBOutlet weak var propertyTypeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // Switches
    @IBOutlet weak var titleDeedsSwitch: UISwitch!
    @IBOutlet weak var centralHeatingSwitch: UISwitch!
    @IBOutlet weak var solarWaterHeatingSwitch: UISwitch!
    @IBOutlet weak var storeRoomSwitch: UISwitch!
    @IBOutlet weak var airConditionerSwitch: UISwitch!
    @IBOutlet weak var furnishedSwitch: UISwitch!
    
    var user: FUser?
    var property: Property?
    
    var titleDeedsSwitchValue = false
    var centralHeatingSwitchValue = false
    var solarWaterHeatingSwitchValue = false
    var storeRoomSwitchValue = false
    var airConditionerSwitchValue = false
    var furnishedSwitchValue = false
    
    var propertyImages : [UIImage] = []
    
    //
    override func viewWillAppear(_ animated: Bool) {
        
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        locationManagerStop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupYearArray()
        
        referenceCodeTextField.delegate = self
        titleTextField.delegate = self
        roomsTextField.delegate = self
        bathroomsTextField.delegate = self
        propertySizeTextField.delegate = self
        balconySizeTextField.delegate = self
        parkingTextField.delegate = self
        floorTextField.delegate = self
        addressTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        advertisementTypeTextField.delegate = self
        avaliableFromTextField.delegate = self
        buildYearTextField.delegate = self
        propertyTypeTextField.delegate = self
        priceTextField.delegate = self
        
        setupPickers()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: topView.frame.size.height)
    }

    
    
    //MARK: IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        user = FUser.currentUser()
        if !user!.isAgent {
            //check if user can post
            save()
        } else {
            save()
        }
    }
    @IBAction func cameraButtonPressed(_ sender: Any) {
        
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = kMAXIMAGENUMBER
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func mapPinButtonPressed(_ sender: Any) {
        //show map so the user can pick a location
        let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapVC
        mapView.delegate = self
        self.present(mapView, animated: true, completion: nil)
        
    }
    @IBAction func currentLocationButtonPressed(_ sender: Any) {
        print("current location")
        locationMangerStart()
    }
    
    
    //MARK: Helper Functions
    
    func setupYearArray() {
        for i in 1800...2030 {
            yearArray.append(i)
        }
        yearArray.reverse()
    }
    
    
    
    func save() {
        if titleTextField.text != "" && referenceCodeTextField.text != "" && advertisementTypeTextField.text != "" && propertyTypeTextField.text != "" && priceTextField.text != "" {
            
            // Create new property
            let newProperty = Property()
           
            
            ProgressHUD.show("Saving...")
            
            
            newProperty.referenceCode = referenceCodeTextField.text!
            newProperty.ownerId = user!.objectId
            newProperty.title = titleTextField.text!
            newProperty.advertismentType = advertisementTypeTextField.text!
            newProperty.price = Int(priceTextField.text!)!
            newProperty.propertyType = propertyTypeTextField.text!
            
            if balconySizeTextField.text != "" {
                newProperty.balconySize = Double(balconySizeTextField.text!)!
            }
            if bathroomsTextField.text != "" {
                newProperty.numberOfBathrooms = Int(bathroomsTextField.text!)!
            }
            if buildYearTextField.text != "" {
                newProperty.buildYear = buildYearTextField.text!
            }
            
            if parkingTextField.text != "" {
                newProperty.parking = Int(parkingTextField.text!)!
            }
            
            if roomsTextField.text != "" {
                newProperty.numberOfRooms = Int(roomsTextField.text!)!
            }
            
            if propertySizeTextField.text != "" {
                newProperty.size = Double(propertySizeTextField.text!)!
            }
            
            if addressTextField.text != "" {
                newProperty.address = addressTextField.text!
            }
            if cityTextField.text != "" {
                newProperty.city = cityTextField.text!
            }
            if countryTextField.text != "" {
                newProperty.country = countryTextField.text!
            }
            
            if avaliableFromTextField.text != "" {
                newProperty.availableFrom = avaliableFromTextField.text!
            }
            
            if floorTextField.text != "" {
                newProperty.floor = Int(floorTextField.text!)!
            }
            if descriptionTextView.text != "" && descriptionTextView.text != "Description" {
                newProperty.propertyDescription = descriptionTextView.text!
            }
            
            if locationCoordinates != nil { // for saving location to backendless :))
                newProperty.latitude = locationCoordinates!.latitude
                newProperty.longitude = locationCoordinates!.longitude
            }
           
            newProperty.titleDeeds = titleDeedsSwitchValue
            newProperty.centralHeating = centralHeatingSwitchValue
            newProperty.solarWaterHeating = solarWaterHeatingSwitchValue
            newProperty.airConditioner = airConditionerSwitchValue
            newProperty.storeRoom = storeRoomSwitchValue
            newProperty.isFurnished = furnishedSwitchValue
            
            
            //Check for property images
            if propertyImages.count != 0 {
                print("555555Uploading5555555")
                uploadImages(images: propertyImages, userId: user!.objectId, referenceNumber: newProperty.referenceCode!, withBlock: { (linkString) in
                    newProperty.imageLinks = linkString
                    newProperty.saveProperty()
                    ProgressHUD.showSuccess("Saved!")
                    print("saved")
                    self.dismissView()
                })
 
            } else {
                newProperty.saveProperty()
                ProgressHUD.showSuccess("Saved!!")
                self.dismissView()
            }
            

            
        } else {
            ProgressHUD.showError("Error: Missing required fields") // !!!Bugs fixed installing 'pod ProgressHUD' and for that installing homebrew.
        }
        ProgressHUD.dismiss()
    }
    
    func dismissView() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
    }
    
    //Switches
    @IBAction func titleDeedsSwitch(_ sender: Any) {
        titleDeedsSwitchValue = !titleDeedsSwitchValue
    }
    @IBAction func centralHeatingSwitch(_ sender: Any) {
        centralHeatingSwitchValue = !centralHeatingSwitchValue
    }
    @IBAction func solarWaterHeatingSwitch(_ sender: Any) {
        solarWaterHeatingSwitchValue = !solarWaterHeatingSwitchValue
    }
    @IBAction func storeRoomSwitch(_ sender: Any) {
        storeRoomSwitchValue = !storeRoomSwitchValue
    }
    @IBAction func airConditionerSwitch(_ sender: Any) {
        airConditionerSwitchValue = !airConditionerSwitchValue
    }
    @IBAction func furnishedSwitch(_ sender: Any) {
        furnishedSwitchValue = !furnishedSwitchValue
    }
    
    
    
    //MARK: ImagePickerDelegates
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper")
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done")
        propertyImages = images
        print("number og images \(images.count)")
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: PickerView

    func setupPickers() {
        
        yearPicker.delegate = self
        propertyTypePicker.delegate = self
        advertisementTypePicker.delegate = self
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
        
        toolbar.setItems([flexibleBar, doneButton], animated: true)
        
        buildYearTextField.inputAccessoryView = toolbar
        buildYearTextField.inputView = yearPicker
        
        avaliableFromTextField.inputAccessoryView = toolbar
        avaliableFromTextField.inputView = datePicker
        
        propertyTypeTextField.inputAccessoryView = toolbar
        propertyTypeTextField.inputView = propertyTypePicker
        
        advertisementTypeTextField.inputAccessoryView = toolbar
        advertisementTypeTextField.inputView = advertisementTypePicker
    }
    
    @objc func doneButtonPressed() {
        
        self.view.endEditing(true)
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == propertyTypePicker {
            return propertyTypes.count
        }
        
        if pickerView == advertisementTypePicker {
            return advertismentTypes.count
        }
        
        if pickerView == yearPicker {
            return yearArray.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == propertyTypePicker {
            return propertyTypes[row]
        }
        
        if pickerView == advertisementTypePicker {
            return advertismentTypes[row]
        }
        
        if pickerView == yearPicker {
            return "\(yearArray[row])"
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var rowValue = row
        
        if pickerView == propertyTypePicker {
            if rowValue == 0 { rowValue = 1 }
            propertyTypeTextField.text = propertyTypes[rowValue]
            
        }
        
        if pickerView == advertisementTypePicker {
            if rowValue == 0 { rowValue = 1 }
            advertisementTypeTextField.text = advertismentTypes[rowValue]
            
        }
        
        if pickerView == yearPicker {
            buildYearTextField.text = "\(yearArray[row])"
        }
        
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        
        if activeField == avaliableFromTextField {
            avaliableFromTextField.text = "\(components.day!)/\(components.month!)/\(components.year!)"
        }
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    //MARK: Location Manager
    
    func locationMangerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization() // we ask permission
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Faild to get the location")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            //case like parential control
            break
        case .denied:
            locationManager = nil
            ProgressHUD.showError("Please enable location from the Settings")
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated location")
        locationCoordinates = locations.last!.coordinate
    }
    
    //MARK: MapViewDelegate
    
    func didFinishWith(coordinate: CLLocationCoordinate2D) { // This function will be called every time our user drops a pin
        print("hfbjkdls")
        self.locationCoordinates = coordinate
        print("coordinates = \(coordinate)")
    }

    
    
    
    
}
