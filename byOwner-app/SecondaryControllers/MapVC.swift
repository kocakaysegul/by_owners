//
//  MapVC.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 10.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewDelegate {  // for using delegate
    
    func didFinishWith(coordinate: CLLocationCoordinate2D) // This is the coordinate our pin
}

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: MapViewDelegate?
    var pinCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.hadleLongTouch))
        
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        var region = MKCoordinateRegion()
        region.center.latitude = 38.9637
        region.center.longitude = 35.2433
        region.span.latitudeDelta = 100
        region.span.longitudeDelta = 100
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    //MARK: IBActions
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if mapView.annotations.count == 1 && pinCoordinates != nil { // we need to do a check to see if the map actually has a notation on it.
            delegate!.didFinishWith(coordinate: pinCoordinates!)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Helper functions
    
    @objc func hadleLongTouch(gesterRecognizer: UILongPressGestureRecognizer) {
        print("Long touch for the pin")
        if gesterRecognizer.state == .began {
            
            let location = gesterRecognizer.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            
            dropPin(coordinate: coordinates)
            print("Check...")
        }
        
    }
    
    
    func dropPin(coordinate: CLLocationCoordinate2D) {
        
        //remove all the existing pins from the map
        mapView.removeAnnotations(mapView.annotations)
        
        pinCoordinates = coordinate
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    
}



