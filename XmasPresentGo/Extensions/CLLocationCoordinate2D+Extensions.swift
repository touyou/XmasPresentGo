//
//  CLLocationCoordinate2D+Extensions.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/18.
//  Copyright © 2017年 touyou. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    
    func bearing(to coordinate: CLLocationCoordinate2D) -> Double {
        
        let a = sin(coordinate.longitude.radian - longitude.radian) * cos(coordinate.latitude.radian)
        let b = cos(latitude.radian) * sin(coordinate.latitude.radian) - sin(latitude.radian) * cos(coordinate.latitude.radian) * cos(coordinate.longitude.radian - longitude.radian)
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        
        return self.bearing(to: coordinate).degree
    }
}
