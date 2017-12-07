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
import Firebase

class MainViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = false
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
            
            collectionView.register(ModelCollectionViewCell.self)
        }
    }
    @IBOutlet weak var modeLabel: UILabel!
    
    var selectID = 0
    let modelIDs: [ARManager.Model] = [.present, .teddyBear, .gundam, .nintendoDS, .ship, .skateboard]
    
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
            
            if selectID != 0 {
                
                let hitTransform = SCNMatrix4(firstHit.worldTransform)
                let hitPosition = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
                let newNode = ARManager.shared.generateModel(modelIDs[selectID])
                newNode.position = hitPosition
                sceneView.scene.rootNode.addChildNode(newNode)
            } else {
                
                
            }
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

// MARK: - UICollectionView

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectID = indexPath.row
        modeLabel.text = selectID == 0 ? "get" : modelIDs[selectID].modelName
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return modelIDs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ModelCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.modelView.scene = SCNScene()
        cell.modelView.scene?.rootNode.addChildNode(ARManager.shared.generateModel(modelIDs[indexPath.row]))
        
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = floor(collectionView.bounds.height)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.zero
    }
}

// MARK: - Storyboard Instatiable

extension MainViewController: StoryboardInstantiable {}
