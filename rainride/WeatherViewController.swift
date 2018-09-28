//
//  WeatherViewController.swift
//  rainride
//
//  Created by Bastian on 07.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import Charts
import CoreLocation

class WeatherViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var temperatureChart: LineChartView!
    @IBOutlet weak var rainChart: LineChartView!
    @IBOutlet weak var cloudChart: LineChartView!
    
    var token: Bool = true
    
    var weatherData: NSDictionary = [:]
    var locationManager : CLLocationManager! = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func drawGraphs (temperatureData: [Double], rainData: [Double], cloudData: [Double], unit: String) {
        let temperatureChartEntry = convertData(data: temperatureData)
        let rainChartEntry = convertData(data: rainData)
        let cloudChartEntry = convertData(data: cloudData)
        
        let temperatureLine = LineChartDataSet(values: temperatureChartEntry, label: "Temperature in °\(unit as String)")
        temperatureLine.colors = [NSUIColor.blue]
        let temperatureData = LineChartData()
        temperatureData.addDataSet(temperatureLine)
        temperatureChart.data = temperatureData
        temperatureChart.chartDescription?.text = "Forecast for the next 48h"
        
        let rainLine = LineChartDataSet(values: rainChartEntry, label: "Percipitation Probability in %")
        rainLine.colors = [NSUIColor.blue]
        let rainData = LineChartData()
        rainData.addDataSet(rainLine)
        rainChart.data = rainData
        rainChart.chartDescription?.text = "Forecast for the next 48h"
        
        let cloudLine = LineChartDataSet(values: cloudChartEntry, label: "Percentage of sky covered in clouds in %")
        cloudLine.colors = [NSUIColor.blue]
        let cloudData = LineChartData()
        cloudData.addDataSet(cloudLine)
        cloudChart.data = cloudData
        cloudChart.chartDescription?.text = "Forecast for the next 48h"
    }
    
    func convertData (data: [Double]) -> [ChartDataEntry] {
        var chartEntry = [ChartDataEntry]()
        for i in 0..<data.count {
            let value = ChartDataEntry(x: Double(i), y: data[i])
            chartEntry.append(value)
        }
        
        return chartEntry
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // THIS NEEDS TO BE BEAUTIFIED
        if self.token {
            self.token = !self.token
            var temperatureUnit: String = "auto"
            if let settings = loadSettings () {
                temperatureUnit = settings.temperatureUnit
            }
            
            var weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(manager.location!.coordinate.latitude),\(manager.location!.coordinate.longitude)?units=auto")
            if (temperatureUnit == "C") {
                weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(manager.location!.coordinate.latitude),\(manager.location!.coordinate.longitude)?units=si")
            } else if (temperatureUnit == "F") {
                weatherURL = NSURL(string: "https://api.darksky.net/forecast/586d4250106f5bb62fb1fd67f943ca03/\(manager.location!.coordinate.latitude),\(manager.location!.coordinate.longitude)?units=us")
            }
            self.getWeatherData(url: weatherURL!)
            
            UserDefaults.standard.set(true, forKey: "getWeatherDataOnce")
            UserDefaults.standard.synchronize()
        }
    }
    
    func getUnit (data: String) -> String {
        if data == "us" {
            return "F"
        } else {
            return "C"
        }
    }
    
    func getWeatherData (url: NSURL) {
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                let forecast = jsonData!["hourly"] as? NSDictionary
                let forecastData = forecast!["data"] as? NSArray
                
                var temperatureData : [Double] = []
                var rainData : [Double] = []
                var cloudData : [Double] = []
                
                let unit = self.getUnit(data: (jsonData!["flags"] as? NSDictionary)!["units"] as! String)
                
                for item in forecastData! {
                    let data = item as? NSDictionary
                    temperatureData.append(data!["temperature"]! as! Double)
                    rainData.append(data!["precipProbability"]! as! Double * 100)
                    cloudData.append(data!["cloudCover"]! as! Double * 100)
                }
                
                self.drawGraphs(temperatureData: temperatureData, rainData: rainData, cloudData: cloudData, unit: unit)
            }
        }).resume()
    }
    
    @IBAction func creditsButtonClicked(_ sender: Any) {
        if let url = URL(string: "https://darksky.net/poweredby/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadSettings() -> Settings?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Settings.ArchiveURL.path) as? Settings
    }
}
