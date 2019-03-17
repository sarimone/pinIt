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

protocol MapBlogDelegate {
    func savePin (index: Int, pin:Pin)
    
    
}
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
    
    func refreshAnnotations() {
        for annotation in myMapView.annotations {
            myMapView.removeAnnotation(annotation);
            myMapView.addAnnotation(annotation);
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Alart either cancel the pin or define the pin
        guard let pinView = view as? PinMKAnnotationView else { return }
        guard let pin = pinView.pin else { return }
        guard let index = self.locations.index(of:pin) else { return }
        
        if pin.visited == nil {
            
            let alert = UIAlertController(title: "Location Status", message: "Add or Cancel?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Visited?", style: .default, handler: {(alert: UIAlertAction!) in
                self.locations[index].visited = true
                self.refreshAnnotations()
                self.performSegue(withIdentifier: "showBlogVC", sender: index)
            }))
            alert.addAction(UIAlertAction(title: "To Visit", style: .default, handler: {(alert: UIAlertAction!) in
                self.locations[index].visited = false
                self.refreshAnnotations()
                self.performSegue(withIdentifier: "showBlogVC", sender: index)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{(alertAction:UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "showBlogVC", sender: index)
        }
        
    }
    
  
    var locations: [Pin] = [
//        Pin(name: "Pickwick Hotel", visited: false, location:CLLocationCoordinate2D(latitude: 37.7834, longitude: -122.406417), images: [
//            UIImage(named: "1")!, UIImage(named: "2")!]),
//        Pin(name:"Fashion Institute", visited: true, location:CLLocationCoordinate2D(latitude: 37.785836, longitude: -122.406410), images: [UIImage(named: "3")!])
    ]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        loadPins()
//        self.myMapView.addAnnotations(self.locations)
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let blogVC = segue.destination as? BlogViewController {
            guard let index = sender as! Array<Pin>.Index? else { return }
            blogVC.pin = self.locations[index]
            blogVC.index = index
            blogVC.mapViewDelegate = self as MapBlogDelegate
        }
        
    }
    
    func savePins() {
        if #available(iOS 12.0, *) {
            // use iOS 12-only feature
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: locations, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "TESTSERST")
            } catch {
                print("Saving not successfull")
                return
            }
        } else {
            // handle older versions
            let data = NSKeyedArchiver.archivedData(withRootObject: locations)
            UserDefaults.standard.set(data, forKey: "TESTSERST")
        }
    }
    
    func loadPins() {
        let pinsData = UserDefaults.standard.object(forKey: "TESTSERST") as? Data
        myMapView.removeAnnotations(myMapView.annotations)
        locations = []
        if let pinsData = pinsData {
            do {
                let pinArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(pinsData) as? [Pin]
                locations = pinArray ?? []
            } catch {
                print("pins not loaded")
            }
        }
        myMapView.addAnnotations(locations)
    }
}


extension MapViewController: MapBlogDelegate {
    
    func savePin (index: Int, pin: Pin){
        locations[index] = pin
        refreshAnnotations()
        savePins()
    }
}
