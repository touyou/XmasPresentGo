//
//  ARManager.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/17.
//  Copyright © 2017年 touyou. All rights reserved.
//

import SceneKit
import ARKit

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
