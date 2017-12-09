//
//  ARManager+Extensions.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/18.
//  Copyright © 2017年 touyou. All rights reserved.
//

import SceneKit

extension ARManager: SCNModelGeneratable {
    
    typealias ModelEnumType = Model
    
    enum Model: Int {
        case teddyBear
        case gundam
        case nintendoDS
        case present
        case ship
        case skateboard
        
        var fileName: String {
            
            switch self {
            case .teddyBear:
                return "teddy_bear.scn"
            case .gundam:
                return "gundam.scn"
            case .nintendoDS:
                return "art.scnassets/nintendods.scn"
            case .present:
                return "art.scnassets/present.scn"
            case .ship:
                return "art.scnassets/ship.scn"
            case .skateboard:
                return "art.scnassets/skateboard.scn"
            }
        }
        
        var modelName: String {
            
            switch self {
            case .teddyBear:
                return "teddy_bear"
            case .gundam:
                return "gundam"
            case .nintendoDS:
                return "nintendods"
            case .present:
                return "present"
            case .ship:
                return "ship"
            case .skateboard:
                return "skateboard"
            }
        }
    }
    
    func generateModel(_ model: Model) -> SCNNode {
        
        guard let scene = SCNScene(named: model.fileName) else {
            
            assert(false, "モデルのファイル名が間違っています。")
            fatalError()
        }
        
        guard let node = scene.rootNode.childNode(withName: model.modelName, recursively: true) else {
            
            assert(false, "指定されたモデルが見つかりません。")
            fatalError()
        }
        
        switch model {
            
        case .teddyBear:
            node.scale = SCNVector3Make(0.002, 0.002, 0.002)
        case .gundam:
            // Cannot change the scale
            node.transform = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0)
        case .nintendoDS:
            node.scale = SCNVector3Make(0.002, 0.002, 0.002)
        case .present:
            node.scale = SCNVector3Make(0.1, 0.1, 0.1)
        case .ship:
            break
        case .skateboard:
            node.scale = SCNVector3Make(0.002, 0.002, 0.002)
        }
        
        return node
    }
}
