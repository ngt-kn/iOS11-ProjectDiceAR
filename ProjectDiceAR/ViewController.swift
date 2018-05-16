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
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Set the view's delegate
        sceneView.delegate = self
        // Enable lighting for 3d effect
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
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
            // create new constant touch location with first location
            let touchLocation = touch.location(in: sceneView)
        
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
               addDice(atLocation: hitResult)
            }
        }
    }
    
    // Places dice on plane of touch location
    func addDice(atLocation location: ARHitTestResult) {
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // place dice on plane, will recusivley search for name
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                location.worldTransform.columns.3.z
            )
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    // re-rolls all placed die
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    // rolls one dice
    func roll(dice: SCNNode) {
        // random rotation for x and y axis
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        // rotation animation
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5
            )
        )
    }
    
    // roll all dice
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    // roll all dice shake gesture
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }

    // removes all dice in array from parent node
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }

    //MARK: - ARkit sceneView delegate methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }

    //MARK: - Plane creation methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
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
        
        return planeNode
    }
}
