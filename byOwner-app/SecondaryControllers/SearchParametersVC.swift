//
//  SearchParametersVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 6.01.2019.
//  Copyright © 2019 Ayşegül Koçak. All rights reserved.
//

import UIKit
import ProgressHUD

protocol SearchParametersViewControllerDelegate {
    func didFinishSettingParameters(whereClause: String)
}

class SearchParametersVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var advertisementTypeTF: UITextField!
    @IBOutlet weak var propertyTypeTF: UITextField!
    @IBOutlet weak var bedroomsTF: UITextField!
    @IBOutlet weak var bathroomsTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var buildYearTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var areaTF: UITextField!
    
    var delegate: SearchParametersViewControllerDelegate?
    
    var furnishedSwitchValue = false
    var centralHeatingSwitchValue = false
    var airConditionerSwitchValue = false
    var solarWaterSwitchValue = false
    var storageRoomSwitchValue = false

    
    var propertyTypePicker = UIPickerView()
    var advertisementTyprPicker = UIPickerView()
    var bedroomPicker = UIPickerView()
    var bathroomPicker = UIPickerView()
    var pricePicker = UIPickerView()
    var yearPicker = UIPickerView()
    
    var yearArray: [String] = []
    
    let minPriceArray = ["Minimum", "Any", "10000", "20000", "30000", "40000", "50000", "60000", "70000", "80000", "90000", "100000", "200000", "500000"]
    
    let maxPriceArray = ["Maximum", "Any", "10000", "20000", "30000", "40000", "50000", "60000", "70000", "80000", "90000", "100000", "200000", "500000"]
    
    var bathroomsArray = ["Any", "1+", "2+", "3+"]
    var bedroomsArray = ["Any", "1+", "2+", "3+", "4+", "5+"]
    
    var activeTextField: UITextField?
    
    var minPrice = ""
    var maxPrice = ""
    var whereClause = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupArray()
        setupPickers()
        
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: mainView.frame.size.height + 30)


    }

    //MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //DONE BUTTON
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if advertisementTypeTF.text != "" && propertyTypeTF.text != "" { // Control for essential parameters
            
            //exact the same in backendless -> advertismentType
            whereClause = "advertismentType = '\(advertisementTypeTF.text!)' and propertyType = '\(propertyTypeTF.text!)' "  //this is our standard where clause which requires search parameters.
            
            
            if bedroomsTF.text != "" && bedroomsTF.text != "Any" {
                let index = bedroomsTF.text!.index(bedroomsTF.text!.startIndex, offsetBy: 0)
                
                let bedroomNumber = bedroomsTF.text![index]
                whereClause = whereClause + " and nuberOfRooms >= \(bedroomNumber)"
            }
            
            if bathroomsTF.text != "" && bathroomsTF.text != "Any" {
                let index = bathroomsTF.text!.index(bathroomsTF.text!.startIndex, offsetBy: 0)
                let bathroomNuber = bathroomsTF.text![index]
                
                whereClause = whereClause + " and numberOfBathrooms >= \(bathroomNuber)"
            }
            
            if priceTF.text != "" && priceTF.text != "Any-Any" {
                
                minPrice = priceTF.text!.components(separatedBy: "-").first!
                maxPrice = priceTF.text!.components(separatedBy: "-").last!
                
                if minPrice == "" {minPrice = "Any"}
                if maxPrice == "" {maxPrice = "Any"}
                
                if minPrice == "Any" && maxPrice != "Any" {
                    whereClause = whereClause + " and price <= \(maxPrice)"
                }
                
                if maxPrice == "Any" && minPrice != "Any" {
                    whereClause = whereClause + " and price >= \(minPrice)"
                }
                
                if maxPrice != "Any" && minPrice != "Any" {
                    whereClause = whereClause + " and price > \(minPrice) and price < \(maxPrice)"
                }
            }
            
            if buildYearTF.text != "" && buildYearTF.text != "Any" {
                whereClause = whereClause + " and buildYear = '\(buildYearTF.text!)'"
            }
            
            if cityTF.text != "" {
                
                whereClause = whereClause + " and city = '\(cityTF.text!)'"
            }
            
            if countryTF.text != "" {
                whereClause = whereClause + " and country = '\(countryTF.text!)'"
            }
            
            if areaTF.text != "" {
                whereClause = whereClause + " and size >= \(areaTF.text!)"
            }
            
            
            //switches
            
            if furnishedSwitchValue {
                whereClause = whereClause + " and isFurnished = \(furnishedSwitchValue)"
            }
            if centralHeatingSwitchValue {
                whereClause = whereClause + " and centralHeating = \(centralHeatingSwitchValue)"
            }
            if airConditionerSwitchValue {
                whereClause = whereClause + " and airConditioner = \(airConditionerSwitchValue)"
            }
            if solarWaterSwitchValue {
                whereClause = whereClause + " and solarWaterHeating = \(solarWaterSwitchValue)"
            }
            if storageRoomSwitchValue {
                whereClause = whereClause + " and storeRoom = \(storageRoomSwitchValue)"
            }
            
            print(whereClause)
            
            delegate!.didFinishSettingParameters(whereClause: whereClause)
            self.dismiss(animated: true, completion: nil)
            
        } else {
            ProgressHUD.showError("Missing required fields!")
            print("Invalid search parameters")
        }
        
    }
    
    
    
    
    
    @IBAction func furnishedSwitchValueChanged(_ sender: Any) {
        furnishedSwitchValue = !furnishedSwitchValue
    }
    
    @IBAction func centralHeatingSwitchValueChanged(_ sender: Any) {
        centralHeatingSwitchValue = !centralHeatingSwitchValue
    }
    
    @IBAction func airConditionerSwitchValueChanged(_ sender: Any) {
        airConditionerSwitchValue = !airConditionerSwitchValue
    }
    
    @IBAction func solarWaterHeatingSwitchValueChanged(_ sender: Any) {
        solarWaterSwitchValue = !solarWaterSwitchValue
    }
    
    @IBAction func storeRoomSwitchValueChanged(_ sender: Any) {
        storageRoomSwitchValue = !storageRoomSwitchValue
    }
    
    
    //MARK: PickerviewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == pricePicker {
            return 2
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case propertyTypePicker:
            return propertyTypes.count
        case advertisementTyprPicker:
            return advertismentTypes.count
        case yearPicker:
            return yearArray.count
        case pricePicker:
            return minPriceArray.count
        case bedroomPicker:
            return bedroomsArray.count
        case bathroomPicker:
            return bathroomsArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView {
        case propertyTypePicker:
            return propertyTypes[row]
        case advertisementTyprPicker:
            return advertismentTypes[row]
        case yearPicker:
            return yearArray[row]
        case pricePicker:
            
            if component == 0 {
                return minPriceArray[row]
            } else {
                return maxPriceArray[row]
            }
            
        case bedroomPicker:
            return bedroomsArray[row]
        case bathroomPicker:
            return bathroomsArray[row]
        default:
            return ""
        }
    }
    
    //MARK: PickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        var rowValue = row
        
        switch pickerView {
        case propertyTypePicker:
            if rowValue == 0 {rowValue = 1}
            propertyTypeTF.text = propertyTypes[rowValue]
        case advertisementTyprPicker:
            if rowValue == 0 {rowValue = 1}
            advertisementTypeTF.text = advertismentTypes[rowValue]
        case yearPicker:
            buildYearTF.text = yearArray[row]
            
        case pricePicker:
            
            if rowValue == 0 {rowValue = 1}
            
            if component == 0 {
                minPrice = minPriceArray[rowValue]
            } else {
                maxPrice = maxPriceArray[rowValue]
            }
            priceTF.text = minPrice + "-" + maxPrice
            
        case bedroomPicker:
            bedroomsTF.text = bedroomsArray[row]
        case bathroomPicker:
            bathroomsTF.text = bathroomsArray[row]
        default: break
        }
        
    }

    
    
    
    
    //MARK: Helper
    
    func setupPickers() {
        
        yearPicker.delegate = self
        propertyTypePicker.delegate = self
        advertisementTyprPicker.delegate = self
        bedroomPicker.delegate = self
        bathroomPicker.delegate = self
        pricePicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissButtonPressed))
        
        toolBar.setItems([flexibleBar, doneButton], animated: true)
        
        buildYearTF.inputAccessoryView = toolBar
        buildYearTF.inputView = yearPicker
        
        propertyTypeTF.inputAccessoryView = toolBar
        propertyTypeTF.inputView = propertyTypePicker
        
        advertisementTypeTF.inputAccessoryView = toolBar
        advertisementTypeTF.inputView = advertisementTyprPicker
        
        bedroomsTF.inputAccessoryView = toolBar
        bedroomsTF.inputView = bedroomPicker
        
        bathroomsTF.inputAccessoryView = toolBar
        bathroomsTF.inputView = bathroomPicker
        
        priceTF.inputAccessoryView = toolBar
        priceTF.inputView = pricePicker
    }
    
    
    @objc func dismissButtonPressed() {
        self.view.endEditing(true)
    }
    
    
    func setupArray() {
        
        for i in 1800...2020 {
            yearArray.append("\(i)")
        }
        yearArray.append("Any")
        yearArray.reverse()
    }
    
    
}
