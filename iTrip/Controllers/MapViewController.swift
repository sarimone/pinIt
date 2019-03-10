//
//  MapViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/21/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    // updates and showes the user's current location
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        myMapView.setRegion(region, animated:true)
        self.myMapView.showsUserLocation = true
    }
    
    
    @IBAction func searchBtn(_ sender: Any) {
       let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
       // Ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        self.view.addSubview(activityIndicator)
        
        //Hide search Bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil { print("error") }
            else {
                    // Remove annotations
//                let annotations = self.myMapView.annotations
//                self.myMapView.removeAnnotations(annotations)
                
                // Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
//                let newPin = Pin
                
                // create annotation
                let pin = Pin(name: searchBar.text ?? "undefined", visited: nil, location: CLLocationCoordinate2DMake(latitude!, longitude!))
//                self.myMapView.addAnnotation(annotation)
                self.locations.append(pin)
                self.myMapView.addAnnotation(pin)
                
                // zoom in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude! ,longitude: longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate,span: span)
                self.myMapView.setRegion(region, animated: true)
                
            }
        }

    }
//
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if let pin = annotation as? Pin {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: pin.identifier){
                return view
            } else {
                let view = PinMKAnnotationView(annotation: pin, reuseIdentifier: pin.identifier)
//                view.image = pin.image()
                view.isEnabled = true
                view.canShowCallout = true
                //view.leftCalloutAccessoryView = UIImageView(image: pin)
                return view
            }
        }
        return nil
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { return nil }
//    guard !(annotation is MKUserLocation) else {
    
//    var selectedPinIndex = -1
//
//    func goToSelectedPin(visited: Bool) {
//        guard selectedPin != nil else {return}
//        selectedPin!.visited = visited
//        self.performSegue(withIdentifier: "showBlogVC", sender: selectedPin)
//    }
//
//    func visitedLocation(alert: UIAlertAction!) {
//        //write one line of code like showAnnotation or addAnnotation or selectAnnotation to redirect to the customAnnotation view method
//        goToSelectedPin(visited: true)
//    }
//
//    func toVisitLocation(alert: UIAlertAction!) {
//
//        //write one line of code like showAnnotation or addAnnotation or selectAnnotation to redirect to the customAnnotation view method
//        // bool value is required to know wheichone is selected ....
//        goToSelectedPin(visited: false)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Alart either cancel the pin or define the pin
        guard let pinView = view as? PinMKAnnotationView else { return }
        guard let pin = pinView.pin else { return }
        
        
        if pin.visited == nil {
            
            let alert = UIAlertController(title: "Location Status", message: "Add or Cancel?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Visited?", style: .default, handler: {(alert: UIAlertAction!) in
                pin.visited = true
                self.performSegue(withIdentifier: "showBlogVC", sender: pin)
            }))
            alert.addAction(UIAlertAction(title: "To Visit", style: .default, handler: {(alert: UIAlertAction!) in
                pin.visited = false
                self.performSegue(withIdentifier: "showBlogVC", sender: pin)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{(alertAction:UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "showBlogVC", sender: pin)
        }
        
    }
    
  
    var locations: [Pin] = [
        Pin(name: "Pickwick Hotel", visited: false, location:CLLocationCoordinate2D(latitude: 37.7834, longitude: -122.406417)),
        Pin(name:"Fashion Institute", visited: true, location:CLLocationCoordinate2D(latitude: 37.785836, longitude: -122.406410))]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
//        for i in locations {
//            let annotation = MKPointAnnotation()
//            //annotation.title = searchBar.text
//            annotation.coordinate = i.location
//            annotationView
//
//
//
//            self.myMapView.addAnnotation(annotation)
//
//        }
   
        
        
        self.myMapView.addAnnotations(self.locations)
   
    }
 


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let blogVC = segue.destination as? BlogViewController {
            guard let pin = sender as? Pin else { return }
            blogVC.pin = pin
        }
        
    }

}




