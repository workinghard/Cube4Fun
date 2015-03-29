//
//  GameViewController.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        // create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.dae")!
        let scene = PrimitivesScene();
        
        
        // create and add a camera to the scene
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 11
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.name = "myCamera"
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        var newAngle = (CGFloat)(20.0)*(CGFloat)(M_PI)/180.0
        //newAngle += currentAngle

//        cameraNode.transform = SCNMatrix4MakeRotation(-0.5, 0, 0, 1)

        cameraNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        cameraNode.transform = SCNMatrix4MakeRotation(-0.4, 1, 0, 0)
        cameraNode.position = SCNVector3(x: 0, y: 13, z: 30)
        //cameraNode.eulerAngles = SCNVector3(x: 1.0, y: 0.0, z: 0.0)


  /*
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        cameraNode.camera = camera
        let cameraOrbit = SCNNode()
        cameraOrbit.name = "myCamera"
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
*/

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.light!.color = NSColor.grayColor()
        lightNode.position = SCNVector3(x: 20, y: 40, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
  
        
        
        /*
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)
        */

        // set the scene to the view
        self.gameView!.scene = scene
        
        // allows the user to manipulate the camera
        //self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
    }

}
