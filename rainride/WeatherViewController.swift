//
//  WeatherViewController.swift
//  rainride
//
//  Created by Bastian on 07.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import Charts

class WeatherViewController: UITableViewController {
    
    @IBOutlet weak var temperatureChart: LineChartView!
    @IBOutlet weak var rainChart: LineChartView!
    @IBOutlet weak var cloudChart: LineChartView!
    
    var weatherData: NSDictionary = [:]
    
    var temperatureData: [Double] = []
    var rainData: [Double] = []
    var cloudData: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        drawGraphs()
    }
    
    func getData () {
        let forecast = weatherData["hourly"] as? NSDictionary
        let forecastData = forecast!["data"] as? NSArray
        
        for item in forecastData! {
            let data = item as? NSDictionary
            self.temperatureData.append(data!["temperature"]! as! Double)
            self.rainData.append(data!["precipProbability"]! as! Double * 100)
            self.cloudData.append(data!["cloudCover"]! as! Double * 100)
        }
    }


    func drawGraphs () {
        let temperatureChartEntry = convertData(data: self.temperatureData)
        let rainChartEntry = convertData(data: self.rainData)
        let cloudChartEntry = convertData(data: self.cloudData)
        
        let unit = getUnit(data: (self.weatherData["flags"] as? NSDictionary)!["units"] as! String)
        
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
    
    func getUnit (data: String) -> String {
        if data == "us" {
            return "F"
        } else {
            return "C"
        }
    }
    
    func convertData (data: [Double]) -> [ChartDataEntry] {
        var chartEntry = [ChartDataEntry]()
        for i in 0..<data.count {
            let value = ChartDataEntry(x: Double(i), y: data[i])
            chartEntry.append(value)
        }
        
        return chartEntry
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
    
    @IBAction func creditsButtonClicked(_ sender: Any) {
        if let url = URL(string: "https://darksky.net/poweredby/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
