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
    func removePin (index: Int)
}

class MapViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var mapBufferOverlay: UIImageView!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBarLeadingConstraint: NSLayoutConstraint!
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
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered && !mapBufferOverlay.isAnimating && !mapBufferOverlay.isHidden {
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.mapBufferOverlay.alpha = 0.0
            }, completion: { _ in
                self.mapBufferOverlay.isHidden = true
            })
        }
    }
    
    @IBAction func searchBtnClick(_ sender: Any) {
        showSearch()

    }
    
    func showSearch() {
        
        self.searchBarLeadingConstraint.constant = 40
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideSearch() {
        
        self.searchBarLeadingConstraint.constant = self.view.frame.width - 80
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func search(_ text: String?) {
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil { print("error") }
            else {
                
                self.addPin(
                    location: CLLocationCoordinate2DMake(
                        response?.boundingRegion.center.latitude ?? 0,
                        response?.boundingRegion.center.longitude ?? 0
                    ),
                    title: text ?? "undefined"
                )
                
            }
        }
    }
    
    func addPin(location: CLLocationCoordinate2D, title: String) {
        var matchingPin: Pin?
        for pin in locations {
            if matchingPin == nil && pin.overlapping(location) {
                matchingPin = pin
            }
        }
        if matchingPin == nil {
            matchingPin = Pin(name: title, visited: nil, location: location)
            self.locations.append(matchingPin!)
            self.myMapView.addAnnotation(matchingPin!)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: matchingPin!.coordinate, span: span)
        self.myMapView.setRegion(region, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pin = annotation as? Pin {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: pin.identifier){
                return view
            } else {
                let view = PinMKAnnotationView(annotation: pin, reuseIdentifier: pin.identifier)
                view.isEnabled = true
                view.canShowCallout = true
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
                self.myMapView.removeAnnotation(pin)
                self.locations.remove(at: index)
                self.refreshAnnotations()
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "showBlogVC", sender: index)
        }
        
    }
    
  
    var locations: [Pin] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBarLeadingConstraint.constant = self.view.frame.width - 80
        
        
        searchTextField.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        loadPins()
   
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
    
    func removePin (index: Int){
        
        myMapView.removeAnnotation(locations[index])
        locations.remove(at: index)
        refreshAnnotations()
        savePins()
    }
    
  
}


extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.returnKeyType == .go) {
            search(searchTextField.text)
            hideSearch()
        }
        return true
    }
}
