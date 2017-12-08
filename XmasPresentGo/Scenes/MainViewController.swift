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
    var addedObjects: [ObjectData] = []
    
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
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        ARCLManager.shared.run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        FirestoreHelper.shared.query = FirestoreHelper.shared.fetchQuery(for: "models")
        FirestoreHelper.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
                
                newNode.objectData = FirestoreHelper.shared.postData(location: MatrixHelper.transformLocation(for: matrix_identity_float4x4, originLocation: ARCLManager.shared.location, location: hitPosition), objectID: modelIDs[selectID])!
                self.addedObjects.append(newNode.objectData)
                
                sceneView.scene.rootNode.addChildNode(newNode)
            } else {
                
                guard let hitObject = sceneView.hitTest(touchLocation, options: nil).first else {
                    
                    print("no hit")
                    return
                }
                
                if hitObject.node.name == ARManager.Model.present.modelName {
                    
                    let objectData = hitObject.node.objectData
                    let newNode = ARManager.shared.generateModel(ARManager.Model(rawValue: objectData.object)!)
                    newNode.objectData = objectData
                    sceneView.scene.rootNode.replaceChildNode(hitObject.node, with: newNode)
                }
            }
        }
    }
}

// MARK: - ARSCNViewDelegate

extension MainViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
        print(error.localizedDescription)
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

// MARK: - Firestore Delegate

extension MainViewController: FirestoreHelperDelegate {
    
    func updateObjects(_ objects: [ObjectData]) {
        
        for object in FirestoreHelper.shared.objects {
            
            guard !self.addedObjects.contains(object) else {
                
                continue
            }
            let location = CLLocation(latitude: object.latitude, longitude: object.longitude)
            let isMe = FirestoreHelper.shared.userId == object.userID
            let (dist, _, _) = VincentyHelper.shared.calcurateDistanceAndAzimuths(at: ARCLManager.shared.coordinate, and: location.coordinate)
            if abs(dist) < 100 {
                
                let newNode = ARManager.shared.generateModel(isMe ? ARManager.Model(rawValue: object.object)! : .present)
                newNode.objectData = object
                let newPosition = SCNMatrix4(MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: ARCLManager.shared.location, location: location))
                newNode.position = SCNVector3Make(newPosition.m41, newPosition.m42, newPosition.m43)
                print(newNode)
                sceneView.scene.rootNode.addChildNode(newNode)
                addedObjects.append(object)
            }
        }
    }
}

// MARK: - Storyboard Instatiable

extension MainViewController: StoryboardInstantiable {}
