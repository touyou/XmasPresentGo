//
//  ViewController.swift
//  XmasPresentGo
//
//  Created by 藤井陽介 on 2017/11/15.
//  Copyright © 2017年 touyou. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        #if DEBUG
        sceneView.showsStatistics = true
        #endif
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // z: North and South, x: East and West, y: parallel to gravity
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
        ARCLManager.shared.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            guard let firstHit = sceneView.hitTest(touchLocation, types: .featurePoint).first else {
                
                return
            }
            
            let hitTransform = SCNMatrix4(firstHit.worldTransform)
            let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
            let newNode = ARManager.shared.generateModel(.present)
            newNode.position = hitPosition
            sceneView.scene.rootNode.addChildNode(newNode)
            print(MatrixHelper.transformLocation(for: matrix_identity_float4x4, originLocation: ARCLManager.shared.location, location: hitPosition).coordinate)
            print(ARCLManager.shared.location.altitude + Double(hitPosition.z))
        }
    }
}

// MARK: - ARSCNViewDelegate

extension MainViewController: ARSCNViewDelegate {
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - Storyboard Instatiable

extension MainViewController: StoryboardInstantiable {}
