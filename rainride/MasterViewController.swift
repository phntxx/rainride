//
//  MasterViewController.swift
//  rainride
//
//  Created by Bastian on 06.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MasterViewController: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var exitLabel: UILabel!

    var token : Int = 0
    var locationManager : CLLocationManager! = CLLocationManager()
    var currentHeading: String = ""

    var restAreaData: [Any] = []
    var exitData: [Any] = []
    var weatherData: NSDictionary = [:]

    var speedUnit: String = "km/h"
    var range: Float = 25
    var temperatureUnit: String = "auto"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let settings = loadSettings () {
            self.speedUnit = settings.speedUnit
            self.range = settings.range
            self.temperatureUnit = settings.temperatureUnit
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if (CLLocationManager.headingAvailable()) {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
            print(self.currentHeading)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSpeed" {
            let controller = (segue.destination as! UINavigationController).topViewController as! SpeedViewController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "showWeather" {
            let controller = (segue.destination as! UINavigationController).topViewController as! WeatherViewController
            controller.weatherData = self.weatherData
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "showExits" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ExitsViewController
            controller.exitData = self.exitData
            controller.restAreaData = self.restAreaData
            controller.currentHeading = self.currentHeading
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (token == 0) {
            let locValue : CLLocationCoordinate2D = manager.location!.coordinate
            getExitData(location: locValue, distance: (self.range * 1000))
            getRestAreaData(location: locValue, distance: (self.range * 1000))

            if (self.temperatureUnit == "C") {
                getWeatherData(location: locValue, unit: "si")
            } else if (self.temperatureUnit == "F") {
                getWeatherData(location: locValue, unit: "us")
            } else {
                getWeatherData(location: locValue, unit: "auto")
            }

            token = 1
        }

}

    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        let direction: Float = Float(heading.magneticHeading)
        headingLabel.text = "Heading: \(convertHeading(heading: direction))"
        self.currentHeading = convertHeading(heading: direction)
    }
    
    func getWeatherData (location: CLLocationCoordinate2D, unit: String) {
        let weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(location.latitude),\(location.longitude)?units=\(unit)")
        URLSession.shared.dataTask(with: (weatherURL as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                self.weatherData = jsonData!
                let currentData = jsonData!["currently"] as! NSDictionary
                DispatchQueue.main.async {
                    self.weatherLabel.text = "Currently it's \(currentData["summary"] as! String) with a temperature of \(currentData["temperature"] as! NSNumber)"
                }
            }
        }).resume()
    }
    
    func getExitData (location: CLLocationCoordinate2D, distance: Float) {
        let exitURL = NSURL(string: "http://overpass-api.de/api/interpreter?data=[out:json];node[highway=motorway_junction](around:\(distance),\(location.latitude),\(location.longitude));out%20meta;")
        URLSession.shared.dataTask(with: (exitURL as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                let items = jsonData!["elements"] as! NSArray
                for item in items {
                    let exit = item as! NSDictionary
                    self.exitData.append([exit["lat"] as! NSNumber, exit["lon"] as! NSNumber])
                }
            }
        }).resume()
    }
    
    func getRestAreaData (location: CLLocationCoordinate2D, distance: Float) {
        let restAreaURL = NSURL(string: "http://overpass-api.de/api/interpreter?data=[out:json];node[highway=rest_area](around:\(distance),\(location.latitude),\(location.longitude));out%20meta;")
        URLSession.shared.dataTask(with: (restAreaURL as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                let items = jsonData!["elements"] as! NSArray
                for item in items {
                    let restArea = item as! NSDictionary
                    self.restAreaData.append([restArea["lat"] as! NSNumber, restArea["lon"] as! NSNumber])
                }
            }
        }).resume()
    }
    
    func convertHeading (heading: Float) -> String {
        if (11.25 <= heading && heading < 33.75) {
            return "North-Northeast"
        } else if (33.75 <= heading && heading < 56.25) {
            return "North-East"
        } else if (56.25 <= heading && heading < 78.75) {
            return "East-Northeast"
        } else if (78.75 <= heading && heading < 101.25) {
            return "East"
        } else if (101.25 <= heading && heading < 123.75) {
            return "East-Southeast"
        } else if (123.75 <= heading && heading < 146.25) {
            return "South-East"
        } else if (146.25 <= heading && heading < 168.75) {
            return "South-Southeast"
        } else if (168.75 <= heading && heading < 191.25) {
            return "South"
        } else if (191.25 <= heading && heading < 213.75) {
            return "South-Southwest"
        } else if (213.75 <= heading && heading < 236.25) {
            return "South-West"
        } else if (236.25 <= heading && heading < 258.75) {
            return "West-Southwest"
        } else if (258.75 <= heading && heading < 281.25) {
            return "West"
        } else if (281.25 <= heading && heading < 303.75) {
            return "West-Northwest"
        } else if (303.75 <= heading && heading < 326.25) {
            return "North-West"
        } else if (326.25 <= heading && heading < 348.75) {
            return "North-Northwest"
        } else {
            return "North"
        }
    }

    func loadSettings() -> Settings?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Settings.ArchiveURL.path) as? Settings
    }
    
}

