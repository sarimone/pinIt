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
                let annotations = self.myMapView.annotations
                self.myMapView.removeAnnotations(annotations)
                
                // Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                // Alart either cancel the pin or define the pin
                let alert = UIAlertController(title: "Location Status", message: "Add or Cancel?", preferredStyle: .alert)
                
                
                    func visitedLocation(alert: UIAlertAction!) {
                        print("Visited Blog")
                    }
                    
                    func toVisitLocation(alert: UIAlertAction!) {
                        print("ToVisi tBlog")
                    }
                    
                    alert.addAction(UIAlertAction(title: "Visited?", style: .default, handler: visitedLocation))
                    alert.addAction(UIAlertAction(title: "To Visit", style: .default, handler: toVisitLocation))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{(alertAction:UIAlertAction!) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                
                self.present(alert, animated: true, completion: nil)

                
                // create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.myMapView.addAnnotation(annotation)
                
             
                // zoom in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude! ,longitude: longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate,span: span)
                self.myMapView.setRegion(region, animated: true)
                
                }
        }
        

    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
   
    }
 
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




