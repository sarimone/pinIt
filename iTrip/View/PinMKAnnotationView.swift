//
//  PinMKAnnotationView.swift
//  iTrip
//
//  Created by Simon Rothert on 08.03.19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import MapKit

class PinMKAnnotationView: MKAnnotationView {
    
    public var pin: Pin? {
        didSet {
            guard self.pin != nil else { return }
            
            self.image = pin!.image()
            self.setNeedsDisplay()
        }
    }

    override var annotation: MKAnnotation? {
        willSet {
            guard let pin = newValue as! Pin? else {return}
            self.pin = pin
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { return nil }

}
