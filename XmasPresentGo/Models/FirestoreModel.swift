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
    var object: Int
    var userID: String
    
    var dictionary: [String: Any] {
        
        return [
            "latitude": latitude,
            "longitude": longitude,
            "objectID": object,
            "userID": userID
        ]
    }
}

extension ObjectData: DocumentSerializable {
    
    init?(dictionary: [String : Any]) {
        
        guard let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double,
            let objectRaw = dictionary["objectID"] as? Int,
            let userId = dictionary["userID"] as? String else {

                return nil
        }
        
        self.init(latitude: latitude, longitude: longitude, object: objectRaw, userID: userId)
    }
}

extension ObjectData: Equatable {
    
    static func ==(lhs: ObjectData, rhs: ObjectData) -> Bool {
        
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude &&
            lhs.object == rhs.object && lhs.userID == rhs.userID
    }
}
