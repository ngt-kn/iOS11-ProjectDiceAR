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
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Initialize new geometry object
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
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
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        
            diceNode.position = SCNVector3(0, 0, -0.1)
        
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
