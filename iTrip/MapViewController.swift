//
//  MapViewController.swift
//  iTrip
//
//  Created by Sara Bahrini on 2/21/19.
//  Copyright © 2019 Sarimon. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate {
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearch.Request!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearch.Response!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
  

    @IBOutlet weak var myMapView: MKMapView!
    
    @IBAction func searchBtn(_ sender: Any) {
        
      
      
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)

       
//
//        self.searchController.searchBar.delegate = self
//         let searchController = UISearchController(searchResultsController: nil)
//        present(searchController, animated:true, completion:nil)
    
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        
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



