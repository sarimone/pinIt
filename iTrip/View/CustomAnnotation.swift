////
////  CustomAnnotation.swift
////  iTrip
////
////  Created by Sara Bahrini on 3/6/19.
////  Copyright © 2019 Sarimon. All rights reserved.
////
//
//import Foundation
//import MapKit
//
//class CustomAnnotationView : MKAnnotationView {
//
//    override var annotation: MKAnnotation? {
//        willSet {
//            guard let annotation = newValue else {return}
//            switch annotation {
//            case is MKAnnotationView:
//                self.canShowCallout = true
//                self.image = #yourimage
//                self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
//                break
//            default:
//                return
//            }
//            self.setNeedsDisplay()
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { return nil }
//    guard !(annotation is MKUserLocation) else {
//
//
//    let annotationIdentifier = "pin"
//    if let myAnnotation = annotation as? myCustomMKAnnotation {
//    let annotation = myCustomAnnotationView(annotation: siteAnnotation, reuseIdentifier: annotationIdentifier)
//    return annotation
//    }
//    return nil
//    }
//}
