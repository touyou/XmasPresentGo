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
import GLKit.GLKMatrix4

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

// MARK: - Matrix Helper

/// Matrix calcuration helpers
/// matrix_float4x4 is
/// column 0 to 3 and row is x, y, z, w
class MatrixHelper {
    
    static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        
        var matrix: matrix_float4x4 = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    static func translationMatrix(with matrix: matrix_float4x4, for translation: vector_float4) -> matrix_float4x4 {
        
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    /// This method calcurate distance and bearing between one and the other location
    static func transformMatrix(for matrix: simd_float4x4, originLocation: CLLocation, location: CLLocation) -> simd_float4x4 {
        
        let distance = Float(location.distance(from: originLocation))
        let bearing = GLKMathDegreesToRadians(Float(originLocation.coordinate.direction(to: location.coordinate)))
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = MatrixHelper.translationMatrix(with: matrix_identity_float4x4, for: position)
        let rotationMatrix = MatrixHelper.rotateAroundY(with: matrix_identity_float4x4, for: bearing)
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
}

// MARK: - ARKit Extensions

extension SCNScene {}

extension SCNNode {}

extension ARSCNView {}
