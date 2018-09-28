//
//  InterfaceController.swift
//  watchApp Extension
//
//  Created by Bastian on 07.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class InterfaceController: WKInterfaceController {

    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var rainLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    
    var locationManager : CLLocationManager! = CLLocationManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        self.locationManager.delegate = self as? CLLocationManagerDelegate
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.getWeatherData(url: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(manager.location!.coordinate.latitude),\(manager.location!.coordinate.longitude)?units=si")
    }
    
    func getWeatherData (url: String) {
        let weatherURL = NSURL(string: url)
        URLSession.shared.dataTask(with: (weatherURL as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                let currentData = jsonData!["currently"] as! NSDictionary
                DispatchQueue.main.async {
                    self.temperatureLabel.setText("Currently it's \(currentData["temperature"] as! NSNumber).")
                }
            }
        }).resume()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
