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
    
    var restAreaData: [Any] = []
    var exitData: [Any] = []

    var currentLocation: [Any] = []
    
    var token : Bool = true
    
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
        
        if self.token {
            self.token = !self.token
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            UserDefaults.standard.set(true, forKey: "updateMapOnce")
            UserDefaults.standard.synchronize()
        }
        
        var range : Float = 25
        if let settings = loadSettings() {
            range = settings.range
        }
        
        
        let exitURL = NSURL(string: "http://overpass-api.de/api/interpreter?data=[out:json];node[highway=motorway_junction](around:\(range * 1000),\(locValue.latitude),\(locValue.longitude));out%20meta;")
        self.getOverPassData(url: exitURL!, type: "exit")
        let restAreaURL = NSURL(string: "http://overpass-api.de/api/interpreter?data=[out:json];node[highway=rest_area](around:\(range * 1000),\(locValue.latitude),\(locValue.longitude));out%20meta;")
        self.getOverPassData(url: restAreaURL!, type: "restarea")
    }
    
    func getOverPassData (url: NSURL, type: String) {
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                let items = jsonData!["elements"] as! NSArray
                for item in items {
                    if (type == "exit") {
                        let exit = item as! NSDictionary
                        self.exitData.append([exit["lat"] as! NSNumber, exit["lon"] as! NSNumber])
                    } else if (type == "restarea") {
                        let restArea = item as! NSDictionary
                        self.restAreaData.append([restArea["lat"] as! NSNumber, restArea["lon"] as! NSNumber])
                    }
                }
            }
        }).resume()
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
    
    func loadSettings() -> Settings?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Settings.ArchiveURL.path) as? Settings
    }
}
