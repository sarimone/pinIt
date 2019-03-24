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

extension CLLocation {
    
    /// Get distance between two points
    ///
    /// - Parameters:
    ///   - from: first point
    ///   - to: second point
    /// - Returns: the distance in meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

class Pin: NSObject, NSCoding, MKAnnotation {
    
    var visited:Bool?
    var coordinate: CLLocationCoordinate2D
    var identifier = "locations"
    var title: String? = ""
    var images: [UIImage] = []
    
    enum Key: String {
        case visited = "visited"
        case coordinate = "coordinate"
        case coordinateLat = "coordinate-lat"
        case coordinateLng = "coordinate-lng"
        case identifier = "identifier"
        case title = "title"
        case images = "images"
    }
    
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
    
    
    init(name:String, visited:Bool?, location:CLLocationCoordinate2D, images: [UIImage] = []) {
        self.visited = visited
        self.coordinate = location
        self.title = name
        self.images = images
    }
    
    
    func encode(with aCoder: NSCoder) {
        
        let coordinateLatDouble = Double(coordinate.latitude)
        let coordinateLngDouble = Double(coordinate.longitude)
        
        aCoder.encode(title, forKey: Key.title.rawValue)
        aCoder.encode(visited ?? false, forKey: Key.visited.rawValue)
        aCoder.encode(coordinateLatDouble, forKey: Key.coordinateLat.rawValue)
        aCoder.encode(coordinateLngDouble, forKey: Key.coordinateLng.rawValue)
        aCoder.encode(identifier, forKey: Key.identifier.rawValue)
        
        if images.count > 0 {
            var localImages: [Data] = []
            for image in images {
                if let data = image.pngData() {
                    localImages.append(data)
                }
            }
            aCoder.encode(localImages, forKey: Key.images.rawValue)
        }
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: Key.title.rawValue) as? String else { return nil }
        
        let visited = aDecoder.decodeBool(forKey: Key.visited.rawValue)
        
        let coordinateLatDouble = aDecoder.decodeDouble(forKey: Key.coordinateLat.rawValue)
        let coordinateLngDouble = aDecoder.decodeDouble(forKey: Key.coordinateLng.rawValue)
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(coordinateLatDouble), longitude: CLLocationDegrees(coordinateLngDouble))
        
        var images: [UIImage] = []
        if let data = aDecoder.decodeObject(forKey: Key.images.rawValue) as? [Data] {
            
            for image in data {
                if let image = UIImage(data: image) {
                    images.append(image)
                }
            }
        }
        self.init(name:title, visited:visited, location:coordinate, images: images)
    }

    func overlapping(_ pin: Pin) -> Bool {
        return self.overlapping(pin.coordinate)
    }
    
    func overlapping(_ location: CLLocationCoordinate2D) -> Bool {
        let distanceInMeters = CLLocation.distance(from: self.coordinate, to: location)
        return distanceInMeters < 1000 // if distance smaller than 1 km
    }
}
