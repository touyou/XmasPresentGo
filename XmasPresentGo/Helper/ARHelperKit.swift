//
//  ARManager.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/17.
//  Copyright © 2017年 touyou. All rights reserved.
//

import SceneKit
import ARKit
import CoreLocation

/// SCNModelGeneratable Protocol
///
/// usage:
/// - ModelEnumType ... Model enumerations.
/// - generateModel ... Generating model method.
protocol SCNModelGeneratable {
    
    associatedtype ModelEnumType
    func generateModel(_ model: ModelEnumType) -> SCNNode
}

/// ARKit Manager
///
/// It will make some matrix method easier.
public class ARManager: NSObject {
    
    static let shared = ARManager()
    
    
}

/// CoreLocation Manager
///
/// Get longitude attitude altitude
public class ARCLManager {
    
    static let shared = ARCLManager()
    
    // MARK: - Private
    
    private let locationManager: CLLocationManager
    private var _latitude: CLLocationDistance?
    private var _longitude: CLLocationDistance?
    private var _altitude: CLLocationDistance?
    private var _coordinate: CLLocationCoordinate2D?
    
    // MARK: - Internal
    
    /// Latitude (default is 0.0)
    var latitude: CLLocationDistance {
        
        guard let latitude = self._latitude else {
            
            return 0.0
        }
        
        return latitude
    }
    /// Longitude (default is 0.0)
    var longitude: CLLocationDistance {
        
        guard let longitude = self.longitude else {
            
            return 0.0
        }
        
        return longitude
    }
    /// Coordinate2D
    var coordinate: CLLocationCoordinate2D {
        
        guard let coordinate = self._coordinate else {
            
            return CLLocationCoordinate2D(latitude: self.longitude, longitude: self.latitude)
        }
        
        return coordinate
    }
    /// Altitude (default is 0.0)
    var altitude: CLLocationDistance {
        
        guard let altitude = self._altitude else {
            
            return 0.0
        }
        
        return altitude
    }
    
    /// start up location manager
    func enabledCLManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    /// end location manager
    func disableCLManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.stopUpdatingLocation()
        }
    }
}

extension ARCLManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocationManager delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                
                return
        }
        
        _altitude = newLocation.altitude
        _coordinate = newLocation.coordinate
        _longitude = newLocation.coordinate.longitude
        _latitude = newLocation.coordinate.latitude
    }
}

// MARK: - ARKit Extensions

extension SCNScene {}

extension SCNNode {}

extension ARSCNView {}
