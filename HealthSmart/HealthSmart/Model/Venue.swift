//
//  Venue.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/26/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import Foundation
import MapKit

class Venue : NSObject, MKAnnotation{
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
}
