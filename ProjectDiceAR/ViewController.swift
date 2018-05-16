//
//  ViewController.swift
//  ProjectDiceAR
//
//  Created by Kenneth Nagata on 5/15/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Initialize new geometry object
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
//        let sphere = SCNSphere(radius: 0.2)
//
//
//        // declare new material for object texture
//        let material = SCNMaterial()
//        // set the color
//        //material.diffuse.contents = UIColor.red
//        material.diffuse.contents = UIImage(named: "art.scnassets/2k_moon.jpg")
//        // add to object
//        sphere.materials = [material]
//
//        // node determines placement of object x, y, z axis
//        let node = SCNNode()
//        // set position of object x, y, z
//        node.position = SCNVector3(1, 0.1, -0.5 )
//        // assign the bode a geometry object to display
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        

        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                // place dice on plane
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z
                    )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    // random rotation for x and y axis
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    diceNode.runAction(
                        SCNAction.rotateBy(
                            x: CGFloat(randomX * 5),
                            y: 0,
                            z: CGFloat(randomZ * 5),
                            duration: 0.5
                        )
                    )
                }
            }
        }
    }
    
    // ARkit delegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            // Declare a new anchor
            let planeAnchor = anchor as! ARPlaneAnchor
            //Initialze a plane size
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            // declare a new node
            let planeNode = SCNNode()
            // set the planceNodes positon
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            // Tansform the plane node from vertical to horizontal by rotating its angle
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
}
