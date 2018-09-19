//
//  SpeedViewController.swift
//  rainride
//
//  Created by Bastian on 07.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import Charts
import CoreData
import CoreLocation

class SpeedViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedChart: LineChartView!
    
    var token : Int = 0
    var locationManager : CLLocationManager! = CLLocationManager()
    var speeds : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func updateGraph(){
        var lineChartEntry  = [ChartDataEntry]()
        
        for i in 0..<speeds.count {
            let value = ChartDataEntry(x: Double(i), y: speeds[i])
            lineChartEntry.append(value)
        }
        
        let unit = "km/h"
        
        let line = LineChartDataSet(values: lineChartEntry, label: "Speed in \(unit)")
        line.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(line)
        
        speedChart.data = data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let unitFloat = 3.6
        let unitString = "km/h"
        if (locations[0].speed > 0) {
            speedLabel.text = "Speed: \(locations[0].speed * unitFloat) \(unitString)"
            speeds.append(locations[0].speed * unitFloat)
            updateGraph()
        }
    }
    
}
