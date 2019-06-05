//
//  LocationViewController.swift
//  NetXMS Mobile Console
//
//  Created by Eriks Jenkevics on 05/06/2019.
//  Copyright © 2019 Raden Solutions. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController
{
   @IBOutlet var mapView: MKMapView!
   var object: AbstractObject?
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      if let object = object
      {
         title = object.objectName
         
         let geoLocation = object.geolocation
         let initialLocation = CLLocation(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
         centerMapOnLocation(location: initialLocation)
      }
   }
    
   func centerMapOnLocation(location: CLLocation)
   {
      let regionRadius: CLLocationDistance = 1000
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
      let pin = MKPointAnnotation()
      pin.coordinate = location.coordinate
      self.mapView.setRegion(coordinateRegion, animated: true)
      self.mapView.addAnnotation(pin)
      let region = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(exactly: 10000)!, CLLocationDistance(exactly: 10000)!)
      self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
   }
}
