//
//  ViewController.swift
//  testt
//
//  Created by Amritpal Singh on 01/06/20.
//  Copyright © 2020 Amritpal Singh. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    var dice: SCNNode?
    var yRotation : Float = 0
    var cameraNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
/*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, options: nil)
            
            if let hitResult = results.first {
                // when processing hit test result:
                getHitFaceFromNormal(normal: hitResult.localNormal)
            }
        }
    }
   */
    
    private func getHitFaceFromNormal(normal: SCNVector3) {
        print(normal)
        if round(normal.x) == -1 {
            // Left face hit
            print("left")
        } else if round(normal.x) == 1 {
            print("right")
            // Right face hit
        } else if round(normal.y) == -1 {
            print("bottom")
            // Bottom face hit
        } else if round(normal.y) == 1 {
            print("top")
            // Top face hit
        } else if round(normal.z) == -1 {
            print("back")
            // Back face hit
        } else if round(normal.z) == 1 {
            print("front")
            // Front face hit
        } else {
            print("error")
            // Error, no face detected
        }
    }
    
    func setupScene() {
        
        //        self.sceneView = self.view as! SCNView
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //        let scene = SCNScene(named: "white-dice.dae")!
        
        // Setup our scene view:
        setupSceneView(with: scene)
        
        // create and add a camera to the scene
        cameraNode = setupCamera(for: scene)
        
        // create and add a light to the scene
        setupLighting(for: scene)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UIPanGestureRecognizer) {
        if let dice = dice {
            roll(dice: dice)
        }
    }
    
    func setupCamera(for scene: SCNScene!) -> SCNNode {
        // Create and add a camera to the scene:
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25)
        scene.rootNode.addChildNode(cameraNode)
        
        return cameraNode
    }
    
    func setupLighting(for scene: SCNScene!) {
        sceneView.autoenablesDefaultLighting = true
    }
    
    func setupSceneView(with scene: SCNScene!) {
        
        if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(diceNode)
            //                roll(dice: diceNode)
            dice = diceNode
        }
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.clear
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5)
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            print("Up side: \(self.boxUpIndex(self.dice)+1)")
        }
    }
    
    func boxUpIndex(_ boxNode: SCNNode?) -> Int {
        let rotation = boxNode?.orientation
        
        var invRotation = rotation
        invRotation?.w = -(rotation?.w ?? 0.0)

        let up = SCNVector3Make(0, 1, 0)

        //rotate up by invRotation
        let transform = SCNMatrix4MakeRotation(invRotation?.w ?? 0.0, invRotation?.x ?? 0.0, invRotation?.y ?? 0.0, invRotation?.z ?? 0.0)
        let glkTransform = SCNMatrix4ToGLKMatrix4(transform)
        let glkUp = SCNVector3ToGLKVector3(up)
        let rotatedUp = GLKMatrix4MultiplyVector3(glkTransform, glkUp)

        let boxNormals = [
            GLKVector3(
                v: (0, 1, 0)
                ),
            GLKVector3(
                v: (0, 0, 1)
                ),
            GLKVector3(
                v: (1, 0, 0)
                ),
            GLKVector3(
                v: (0, 0, -1)
                ),
            GLKVector3(
                v: (-1, 0, 0)
                ),
            GLKVector3(
                v: (0, -1, 0)
                )
        ]

        var bestIndex = 0
        var maxDot: Float = -1

        for i in 0..<6 {
            let dot = GLKVector3DotProduct(boxNormals[i], rotatedUp)
            if dot > maxDot {
                maxDot = dot
                bestIndex = i
            }
        }

        return bestIndex
    }
}

