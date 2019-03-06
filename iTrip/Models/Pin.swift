//
//  Pin.swift
//  iTrip
//
//  Created by Sara Bahrini on 3/6/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class Pin:NSObject, MKAnnotation {
    
    var visited:Bool?
    var coordinate: CLLocationCoordinate2D
    var identifier = "locations"
    var title: String? = ""
    
    func image() -> UIImage{
        
        if let visited = self.visited {
            if visited {
                return UIImage(named: "visitedPin", in: nil, compatibleWith: nil)!
            } else {
               
                return UIImage(named: "toVisitPin", in: nil, compatibleWith: nil)!
            }
        } else {
            
            return UIImage(named: "searchedPin", in: nil, compatibleWith: nil)!
        }
    }
    
//    func visited(){
//        var visitedLoc = []
//        if
//    }
    
    
    init(name:String, visited:Bool?, location:CLLocationCoordinate2D) {
        self.visited = visited
        self.coordinate = location
        self.title = name
    }

}
