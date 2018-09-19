//
//  SettingsViewController.swift
//  rainride
//
//  Created by Bastian on 13.09.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var temperatureSetting: UISegmentedControl!
    @IBOutlet weak var speedSetting: UISegmentedControl!
    
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var rangeSlider: UISlider!
    
    var unitString: String = "km"
    var unitFloat: Float = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        if let settings = loadSettings() {
            self.unitFloat = settings.speedFloat
            self.rangeSlider.value = settings.range / (25 * settings.speedFloat)
            settings.temperatureUnit == "C" ? (self.temperatureSetting.selectedSegmentIndex = 0) : (self.temperatureSetting.selectedSegmentIndex = 1)
            settings.speedUnit == "km/h" ? (self.speedSetting.selectedSegmentIndex = 0) : (self.speedSetting.selectedSegmentIndex = 1)
        }
        
        updateRangeLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func RangeSliderChanged(_ sender: Any) {
        updateRangeLabel()
    }
    
    @IBAction func speedSettingChanged(_ sender: Any) {
        
        if (self.speedSetting.selectedSegmentIndex == 0) {
            self.unitString = "km"
            self.unitFloat = 1
        } else {
            self.unitString = "miles"
            self.unitFloat = 0.6214
        }
        
        updateRangeLabel()
        
    }
    
    func loadSettings () -> Settings? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Settings.ArchiveURL.path) as? Settings
    }
    
    func updateRangeLabel() {
        let range = 25 * self.rangeSlider.value * self.unitFloat
        self.rangeLabel.text = "Range: \(range) \(self.unitString)"
    }

    @IBAction func darkSkyLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://darksky.net/poweredby/") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    @IBAction func osmLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://www.openstreetmap.org/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let settings = Settings(
            temperatureUnit: (self.temperatureSetting.selectedSegmentIndex == 0 ? "C" : "F"),
            speedUnit: (self.speedSetting.selectedSegmentIndex == 0 ? "km/h" : "mph"),
            speedFloat: (self.unitFloat),
            range: (25 * self.rangeSlider.value * self.unitFloat)
        )
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(settings!, toFile: Settings.ArchiveURL.path)
        if isSuccessfulSave {
            print("Successful save.")
        } else {
            print("Failed to save...")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
