//
//  StoreMapViewController.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/26/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StoreMapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var Map: MKMapView!
    
    var currentPlacemark: CLPlacemark?
    var stores = [StoreLocDetail]()
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        let location = CLLocation()
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        let myLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        Map.setRegion(region, animated: true)
        
        self.Map.showsUserLocation = true
        Map.delegate = self
        
        pointLocationsOnMap()
    }
    
    func pointLocationsOnMap(){
        
        var allLocation = [MKPointAnnotation]()
        for store in stores {
        
            let location = CLLocationCoordinate2DMake(store.latitude, store.longitude)
            //let annotation = MKPointAnnotation()
            
            let venue = Venue(title: store.storeName, coordinate: location)
            
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegion(center: location, span: span)
            
            Map.setRegion(region, animated: true)
            
//            annotation.coordinate = location
//            annotation.title = store.storeName
            
            Map.addAnnotation(venue)
            Map.selectAnnotation( venue, animated: true)
            
            //allLocation.append(venue as? MKAnnotation as! MKPointAnnotation)
            
            //Map.showAnnotations(allLocation, animated: true)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeMap(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getDirection(_ sender: UIButton) {
        guard let currentPlacemark = currentPlacemark else {
            return
        }
        
        let directionRequest = MKDirectionsRequest()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        // calculate the directions / route
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (directionsResponse, error) in
            guard let directionsResponse = directionsResponse else {
                if let error = error {
                    print("error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = directionsResponse.routes[0]
            self.Map.removeOverlays(self.Map.overlays)
            self.Map.add(route.polyline, level: .aboveRoads)
            
            let routeRect = route.polyline.boundingMapRect
            self.Map.setRegion(MKCoordinateRegionForMapRect(routeRect), animated: true)
        }
    
    }
    
}

extension StoreMapViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Venue {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let location = view.annotation {
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 4.0
        
        return renderer
    }
}
