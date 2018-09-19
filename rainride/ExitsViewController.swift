//
//  ExitsViewController.swift
//  rainride
//
//  Created by Bastian on 06.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExitsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentHeading: String = ""
    var restAreaData: [Any] = []
    var exitData: [Any] = []
    var token : Int = 0
    var currentLocation: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        insertPins(locations: self.exitData as NSArray, title: "Exit")
        insertPins(locations: self.restAreaData as NSArray, title: "Rest Area")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLocation = [locValue.latitude, locValue.longitude]
        if (token == 0) {
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            token = 1
        }
        
    }
    
    func insertPins (locations: NSArray, title: String) {
        for location in locations {
            let coordinates = location as! NSArray
            let pin = PinAnnotation(title: title, subtitle: "#\(locations.index(of: location))", coordinate: CLLocationCoordinate2DMake(coordinates[0] as! Double, coordinates[1] as! Double))
            self.mapView.addAnnotation(pin)
            
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.subtitle = "#\(locations.index(of: location))"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func checkDirection (direction: String, lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double{
        if ((direction == "North") || (direction == "North-East") || (direction == "North-West") || (direction == "North-Northeast") || (direction == "North-Northwest")) {
            if(lat2 > lat1) {
                return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
            } else {
                return Double(99999)
            }
        } else if ((direction == "East") || (direction == "North-East") || (direction == "South-East") || (direction == "East-Southeast") || (direction == "East-Northeast")) {
            if (lng2 > lng1) {
                return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
            } else {
                return Double(99999)
            }
        } else if ((direction == "South") || (direction == "South-East") || (direction == "South-West") || (direction == "South-Southeast") || (direction == "South-Southwest")) {
            if (lat2 < lat1) {
                return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
            } else {
                return Double(99999)
            }
        } else if ((direction == "West") || (direction == "North-West") || (direction == "South-West") || (direction == "West-Northwest") || (direction == "West-Southwest")) {
            if (lng2 < lng1) {
                return distanceInKmBetweenEarthCoordinates (lat1: lat1, lng1: lng1, lat2: lat2, lng2: lng2)
            } else {
                return Double(99999)
            }
        }
        return Double(99999)
    }
    
    func distanceInKmBetweenEarthCoordinates (lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let earthRadiusKm = 6371
        let dLat = degreesToRadians (degrees: (lat2-lat1))
        let dLon = degreesToRadians (degrees: (lng2-lng1))
        let latitude1 = degreesToRadians (degrees: lat1)
        let latitude2 = degreesToRadians (degrees: lat2)
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(latitude1) * cos(latitude2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return Double(earthRadiusKm) * Double(c)
    }
    
    func degreesToRadians (degrees: Double) -> Double{
        return (degrees * Double.pi / 180)
    }
}
