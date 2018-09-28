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

    var locationManager : CLLocationManager! = CLLocationManager()
    var weatherData: NSDictionary = [:]
    var updateSettings: Bool!
    var locValue : CLLocationCoordinate2D!

    var token : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if updateSettings == true {
            updateSettings = !updateSettings
            self.updateData()
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
        } else if segue.identifier == "showExits" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ExitsViewController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "showWeather" {
            let controller = (segue.destination as! UINavigationController).topViewController as! WeatherViewController
            controller.weatherData = self.weatherData
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locValue = manager.location!.coordinate
        
        if self.token {
            self.token = !self.token
            self.updateData()
        }
        
    }

    func updateData() {
        var temperatureUnit: String = "auto"
        if let settings = loadSettings () {
            temperatureUnit = settings.temperatureUnit
        }
        
        var weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(locValue.latitude),\(locValue.longitude)?units=auto")
        if (temperatureUnit == "C") {
            weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(locValue.latitude),\(locValue.longitude)?units=si")
        } else if (temperatureUnit == "F") {
            weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(locValue.latitude),\(locValue.longitude)?units=us")
        }
        self.getWeatherData(url: weatherURL!)
    }

     func getWeatherData (url: NSURL) {
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                self.weatherData = jsonData!
                let currentData = jsonData!["currently"] as! NSDictionary
                DispatchQueue.main.async {
                    self.weatherLabel.text = "Currently it's \(currentData["summary"] as! String) with a temperature of \(currentData["temperature"] as! NSNumber)"
                }
            }
        }).resume()
    }

    func loadSettings() -> Settings?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Settings.ArchiveURL.path) as? Settings
    }
    
}

