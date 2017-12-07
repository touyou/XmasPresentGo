//
//  FirestoreModel.swift
//  GirlsHack
//
//  Created by 藤井陽介 on 2017/12/03.
//  Copyright © 2017年 touyou. All rights reserved.
//

import Foundation

struct ObjectData {
    
    var latitude: Double
    var longitude: Double
    var object: ARManager.Model
    var userID: String
    
    var dictionary: [String: Any] {
        
        return [
            "latitude": latitude,
            "longitude": longitude,
            "objectID": object.rawValue,
            "userID": userID
        ]
    }
}

extension ObjectData: DocumentSerializable {
    
    init?(dictionary: [String : Any]) {
        
        guard let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let objectRaw = dictionary["object"] as? Int,
            let userId = dictionary["userId"] as? String else { return nil }
        
        self.init(latitude: latitude, longitude: longitude, object: ARManager.Model(rawValue: objectRaw)!, userID: userId)
    }
}
