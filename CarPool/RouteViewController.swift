//
//  RouteViewController.swift
//  CarPool
//
//  Created by Prachi Verma on 01/12/15.
//  Copyright © 2015 Prachi Verma. All rights reserved.
//


import UIKit
import GoogleMaps


class RouteViewController: NSObject {
    
  
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    let baseURLNearByLoc = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    override init() {
        super.init()
    }
    
    
    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
        if let lookupAddress = address {
            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            
            let geocodeURL = NSURL(string: geocodeURLString)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
                
                var error: NSError?
                do {
                    if let dictionary = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<NSObject, AnyObject> {
                        
                
                    // Get the response status.
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                        self.lookupAddressResults = allResults[0]
                        
                        // Keep the most important values.
                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
                        self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                        self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        
                        completionHandler(status: status, success: true)
                    }
                    else {
                        completionHandler(status: status, success: false)
                    }
                    }
                }catch let error as NSError {
                        print(error.localizedDescription)
                    }
                
            })
        }
        else {
            completionHandler(status: "No valid address.", success: false)
        }
    }
    
    
    func getDirections(origin: String!, destination: String!,mode:String!, waypoints: Array<String>!, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&optimizeWaypoints:true"
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                directionsURLString += "&mode=" + mode;
                
                
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    //var error: NSError?
                   // let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                   
                        
                        do {
                            if let dictionary = try NSJSONSerialization.JSONObjectWithData(directionsData!, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<NSObject, AnyObject> {
                                print(dictionary)
                                let status = dictionary["status"] as! String
                                
                                if status == "OK" {
                                    self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                                    self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                                    
                                    let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                                    
                                    let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                                    self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                    
                                    let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                                    self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                    
                                    self.originAddress = legs[0]["start_address"] as! String
                                    self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                    
                                    self.calculateTotalDistanceAndDuration()
                                    
                                    completionHandler(status: status, success: true)
                                }
                                else {
                                    completionHandler(status: status, success: false)
                                }

                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                  
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    
    func getNearByLocation(currentLocation:String, completionHandler: ((status: String, data:NSMutableArray, success: Bool) -> Void)) {
       
        
        var nearByLocURLString = baseURLNearByLoc + "location=" + currentLocation + "&radius=" + "50" + "&key=AIzaSyBXNMoWLUdDVI1NL-n9HUWiG39JnLSWyf8"
        
                
                
                nearByLocURLString = nearByLocURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let nearByLocURL = NSURL(string: nearByLocURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let nearByData = NSData(contentsOfURL: nearByLocURL!)
                    print(nearByData);
                    
                    //var error: NSError?
                    // let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                    
                    
                    do {
                        if let dictionary = try NSJSONSerialization.JSONObjectWithData(nearByData!, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<NSObject, AnyObject> {
                            print(dictionary)
                            let status = dictionary["status"] as! String
                            
                            let arr = dictionary["results"] as! NSArray;
                            
                            var extractedData = NSMutableArray();
                            
                            let count = arr.count > 3 ? 3 : arr.count as NSInteger;
                            
                            for i in 0 ..< count {
                                let dic = arr[i]
                                let geometry  = dic["geometry"] as! NSDictionary;
                                
                                let location =  geometry["location"] as! NSDictionary;
                                
                                extractedData.addObject(location);
                            }
                            
                            print(extractedData);
                            
                            completionHandler(status: status, data:extractedData, success: true)

                    
                            
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                })
            
    

    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }

       

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
