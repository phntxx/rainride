//
//  PinAnnotation.swift
//  rainride
//
//  Created by Bastian on 07.06.18.
//  Copyright © 2018 phntxx. All rights reserved.
//

import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
