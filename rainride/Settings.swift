//
//  Settings.swift
//  rainride
//
//  Created by Bastian on 19.09.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import UIKit
import os.log


class Settings: NSObject, NSCoding {
    
    //MARK: Properties
    
    var temperatureUnit: String
    var speedUnit: String
    var speedFloat: Float
    var range: Float
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("settings")
    
    //MARK: Types
    
    struct PropertyKey {
        static let temperatureUnit = "temperatureUnit"
        static let speedUnit = "speedUnit"
        static let speedFloat = "speedFloat"
        static let range = "range"
    }
    
    //MARK: Initialization
    
    init?(temperatureUnit: String, speedUnit: String, speedFloat: Float, range: Float) {

        guard !temperatureUnit.isEmpty else {
            return nil
        }
        
        guard !speedUnit.isEmpty else {
            return nil
        }

        guard (range >= 0) && (range <= 25) else {
            return nil
        }

        if temperatureUnit.isEmpty || speedUnit.isEmpty || range < 0  {
            return nil
        }
        
        // Initialize stored properties.
        self.temperatureUnit = temperatureUnit
        self.speedUnit = speedUnit
        self.speedFloat = speedFloat
        self.range = range
        
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit, forKey: PropertyKey.temperatureUnit)
        aCoder.encode(speedUnit, forKey: PropertyKey.speedUnit)
        aCoder.encode(speedFloat, forKey: PropertyKey.speedFloat)
        aCoder.encode(range, forKey: PropertyKey.range)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let temperatureUnit = aDecoder.decodeObject(forKey: PropertyKey.temperatureUnit) as? String else {
            os_log("Unable to decode the unit for the temperatures.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let speedUnit = aDecoder.decodeObject(forKey: PropertyKey.speedUnit) as? String else {
            os_log("Unable to decode the unit for the speeds.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let speedFloat = aDecoder.decodeFloat(forKey: PropertyKey.speedFloat)
        
        let range = aDecoder.decodeFloat(forKey: PropertyKey.range)
        
        
        // Must call designated initializer.
        self.init(temperatureUnit: temperatureUnit, speedUnit: speedUnit, speedFloat: speedFloat, range: range)
        
    }
}

