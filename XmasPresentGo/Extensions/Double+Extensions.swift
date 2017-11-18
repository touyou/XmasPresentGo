//
//  Double+Extensions.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/18.
//  Copyright © 2017年 touyou. All rights reserved.
//

import Foundation

extension Double {
    
    var radian: Double {
        
        return self * .pi / 180.0
    }
    
    var degree: Double {
        
        return self * 180.0 / .pi
    }
}
