//
//  DetailViewController.swift
//  CarPool
//
//  Created by Prachi Verma on 01/12/15.
//  Copyright © 2015 Prachi Verma. All rights reserved.
//

import UIKit
import GoogleMaps;
import CoreLocation


class DetailViewController: UIViewController,CLLocationManagerDelegate, GMSMapViewDelegate  {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var lblInfo : UILabel!


    var latLong = CLLocation();
    var currentLoc: NSString = "";
    var locationManager = CLLocationManager()
    
    var didFindMyLocation = false

    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var routeView = RouteViewController()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var needARide : Bool!;


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }
    
    func getCurrentLocation() {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //[locationManager startUpdatingLocation];
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager();

        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        mapview.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        //locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        
       
        mapview.delegate = self
        
        
        //mapview.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Location Manager helper stuff
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        if (error == true) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            mapview.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
            mapview.settings.myLocationButton = true
            
            didFindMyLocation = true
        }
    }

    
    // authorization status
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate
            
            print(coord.latitude)
            print(coord.longitude)
            self.latLong = locationObj;
            currentLoc = "\(coord.latitude),\(coord.longitude)"
            
            self.showCurrentLoactionOnMap(coord.latitude, longitude: coord.longitude);
        }
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] 
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })

    }
    func showCurrentLoactionOnMap(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 12.0)
        mapview.camera = camera
        originMarker = GMSMarker(position:CLLocationCoordinate2DMake(latitude, longitude))
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.map = mapview;
        
    }
    
    func drawRoute() {
        let route = routeView.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.geodesic = false
        routePolyline.map = mapview
        let customBlueColor = UIColor(red: 1/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        routePolyline.strokeColor = customBlueColor;

    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        self.searchBar.resignFirstResponder()
        
        if((self.needARide) != nil){
            self.showActiveRoute();
        }
        else{
           
        if let polyline = self.routePolyline {
            self.clearRoute()
            self.waypointsArray.removeAll(keepCapacity: false)
        }
        let origin = currentLoc;
        print(currentLoc)
        let destination = searchBar.text;
        
            self.routeView.getDirections(origin as String, destination: destination,mode:"driving", waypoints:nil, completionHandler: { (status, success) -> Void in
            if success {
                
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.displayRouteInfo()
                
            }
            else {
                print(status)
                if(status == "NOT_FOUND" || status == "ZERO_RESULTS"){
                    let alertController = UIAlertController(title: "Invalid Location", message:
                        "Please enter valid Location!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            }
        })
        }
        
    }
    
    func showActiveRoute(){

        self.routeView.getNearByLocation(self.currentLoc as String, completionHandler: { (status, data, success) -> Void in
            if success {
               
                let origin = self.self.currentLoc;

                
                for i in 0 ..< data.count {
                    
                    let Dic = data[i];


                let destinationLatitude = Dic["lat"] as! NSNumber
                let destinationLongitude = Dic["lng"]as! NSNumber;
                
                let destination = "\(destinationLatitude),\(destinationLongitude)"
                
                
                self.routeView.getDirections(origin as String, destination: destination,mode:"walk", waypoints: nil, completionHandler: { (status, success) -> Void in
                    if success {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                        //self.displayRouteInfo()
                    }
                    else {
                        print(status)
                    }
                })
                }

            }
            else {
                print(status)
            }
        })
        
        
        
    }
    func displayRouteInfo() {
        lblInfo.text = routeView.totalDistance + "\n" + routeView.totalDuration
    }

    func configureMapAndMarkersForRoute() {
        mapview.camera = GMSCameraPosition.cameraWithTarget(routeView.originCoordinate, zoom: 12.0)
        originMarker.map = nil
        originMarker = GMSMarker(position: self.routeView.originCoordinate)
        originMarker.map = self.mapview
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.routeView.originAddress
        
        destinationMarker = GMSMarker(position: self.routeView.destinationCoordinate)
        destinationMarker.map = self.mapview
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.routeView.destinationAddress
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = mapview
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    func recreateRoute() {
        if let polyline = routePolyline {
            clearRoute()
            
            routeView.getDirections(routeView.originAddress, destination: routeView.destinationAddress,mode:"driving", waypoints: waypointsArray,  completionHandler: { (status, success) -> Void in
                
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
        }
        
    }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
       
    }

}

