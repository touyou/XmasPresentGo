//
//  VincentryHelper.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/23.
//  Copyright © 2017年 touyou. All rights reserved.
//

import Foundation
import CoreLocation

class VincentryHelper: NSObject {
    
    static let shared = VincentryHelper()
    
    // MARK: - Private
    
    /// Radius at equator [m]
    private let a: Double = 6378137.0
    /// Flattening of the ellipsoid
    private let f: Double = 1 / 298.257223563
    /// Radius at the poles [m]
    private let b: Double = 6356752.314245
    /// Reduced latitude
    private func u(of latitude: Double) -> Double {
        
        return atan((1 - f) * tan(latitude.radian)).degree
    }
    
    // MARK: - Internal
    
    func calcurateDistanceAndAzimuths(at location1: CLLocationCoordinate2D, and location2: CLLocationCoordinate2D) -> (s: Double, a1: Double, a2: Double) {
        
        let dL = location2.longitude - location1.longitude
        let u1 = u(of: location1.latitude)
        let u2 = u(of: location2.latitude)
        
        var lambda = dL
        var lastLambda = dL - 100
        
        var sinsig: Double = 0.0
        var cossig: Double = 0.0
        var sigma: Double = 0.0
        var sinalp: Double = 0.0
        var cos2alp: Double = 0.0
        var cossig2: Double = 0.0
        var C: Double = 0.0
        
        // Calcurate lambda
        while abs(lastLambda - lambda) > pow(10, -12.0) {
            
            sinsig = sqrt(pow(cos(u2.radian) * sin(lambda.radian), 2.0) + pow(cos(u1.radian) * sin(u2.radian) - sin(u1.radian) * cos(u2.radian) * cos(lambda.radian), 2.0))
            cossig = sin(u1.radian) * sin(u2.radian) + cos(u1.radian) * cos(u2.radian) * cos(lambda.radian)
            sigma = atan2(sinsig, cossig).degree
            sinalp = (cos(u1.radian) * cos(u2.radian) * sin(lambda.radian)) / sinsig
            cos2alp = 1 - pow(sinalp, 2.0)
            cossig2 = cossig - (2 * sin(u1.radian) * sin(u2.radian)) / cos2alp
            C = f / 16.0 * cos2alp * (4 + f * (4 - 3 * cos2alp))
            lastLambda = lambda
            lambda = dL + (1 - C) * f * sinalp * (cossig2 + C * cossig * (2 * pow(cossig2, 2.0) - 1))
        }
        
        let u22 = cos2alp * (pow(a, 2.0) - pow(b, 2.0)) / pow(b, 2.0)
        let A = 1 + u22 / 16384 * (4096 + u22 * (u22 * (320 - 175 * u22) - 768))
        let B = u22 / 1024 * (256 + u22 * (u22 * (320 - 175 * u22) - 768))
        let dsigma = B * sinsig * (cossig2 + B / 4 * (cossig * (2 * pow(cossig2, 2.0) - 1) - B / 6 * cossig2 * (4 * pow(sinsig, 2.0) - 3) * (4 * pow(cossig2, 2.0) - 3)))
        
        // Result
        let s = b * A * (sigma - dsigma)
        let a1 = atan2(cos(u2.radian) * sin(lambda.radian), cos(u1.radian) * sin(u2.radian) - sin(u1.radian) * cos(u2.radian) * cos(lambda.radian)).degree
        let a2 = atan2(cos(u1.radian) * sin(lambda.radian), cos(u1.radian) * sin(u2.radian) * cos(lambda.radian) - sin(u1.radian) * cos(u2.radian)).degree
        return (s: s, a1: a1, a2: a2)
    }
    
    func calcurateNextPointLocation(from location: CLLocationCoordinate2D, s: Double, a1: Double) -> (location: CLLocationCoordinate2D, a2: Double) {
        
        let u1 = u(of: location.latitude)
        let sigma1 = atan2(tan(u1.radian), cos(a1.radian))
        let sinalp = cos(u1.radian) * sin(a1.radian)
        let cos2alp = 1 - pow(sinalp, 2.0)
        let u22 = cos2alp * (pow(a, 2.0) - pow(b, 2.0)) / pow(b, 2.0)
        let A = 1 + u22 / 16384 * (4096 + u22 * (u22 * (320 - 175 * u22) - 768))
        let B = u22 / 1024 * (256 + u22 * (u22 * (320 - 175 * u22) - 768))
        
        var sigma = s / b / A
        var lastSigma = sigma - 100
        
        var sigmam: Double = 0.0
        
        while abs(lastSigma - sigma) > 0.000001 {
            
            sigmam = 2 * sigma1 + sigma
            let dsigma = B * sin(sigma.radian) * (cos(sigmam.radian) * (2 * pow(cos(sigmam), 2.0) - 1) - B / 6 * cos(sigmam) * (4 * pow(sin(sigma.radian), 2.0) - 3) * (4 * pow(cos(sigmam), 2.0) - 3))
            lastSigma = sigma
            sigma = s / b / A + dsigma
        }
        
        let lambda = atan2(sin(sigma.radian) * sin(a1.radian), cos(u1.radian) * cos(sigma.radian) - sin(u1.radian) * sin(sigma.radian) * cos(a1.radian)).degree
        let C = f / 16 * cos2alp * (4 + f * (4 - 3 * cos2alp))
        let dL = lambda - (1 - C) * f * sinalp * (sigma + C * sin(sigma.radian) * (cos(sigmam) + C * cos(sigma.radian) * (2 * pow(cos(sigmam.radian), 2.0) - 1)))
        
        // Result
        let latitude = atan2(sin(u1.radian) * cos(sigma.radian) + cos(u1.radian) * sin(sigma) * cos(a1.radian), (1 - f) * sqrt(pow(sinalp, 2.0) + (sin(u1.radian) * sin(sigma.radian) - cos(u1.radian) * cos(sigma.radian) * cos(a1.radian)))).degree
        let longitude = location.longitude + dL
        let a2 = atan2(sinalp, cos(u1.radian) * cos(sigma.radian) * cos(a1.radian) - sin(u1.radian) * sin(sigma.radian)).degree
        return (location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), a2: a2)
    }
}
