//
//  PrimitivesScene.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import Cocoa
import SceneKit
import QuartzCore


class PrimitivesScene: SCNScene {
  override init() {
    super.init()
    
    var radius:CGFloat = 1.0
    
    let yCount = 4
    let zCount = 4
    let xCount = 4
    var myIndex = 0
    
    
    let text = SCNText(string: "Klick", extrusionDepth: 1)
    let textNode = SCNNode(geometry: text)
    textNode.name = "myDescr"
    textNode.position = SCNVector3(x:-12.0 , y: 6.0, z: 0.0)
    textNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
    
    self.rootNode.addChildNode(textNode)
    
    
    let cubeNode = SCNNode()
    cubeNode.name = "cubeNode"
    
    let box = SCNBox(width: 11.0, height: 1.0, length: 11.0, chamferRadius: 0.1)
    box.firstMaterial?.diffuse.contents = NSColor.blueColor()
    let boxNode = SCNNode(geometry: box)
    boxNode.name = "myBox"
    boxNode.position = SCNVector3(x:0.0 , y: -6.0, z: 0.0)
    cubeNode.addChildNode(boxNode)


    var y:CGFloat = -4.5
    for row in 0..<yCount {
        var z:CGFloat = -4.5
        for depth in 0..<zCount {
            var x:CGFloat = -4.5
            for column in 0..<xCount {
                
                let sphereGeometry = SCNSphere(radius: radius)
                sphereGeometry.name = myIndex.description
                
                if (row % 2 == 0) {
                    sphereGeometry.firstMaterial?.diffuse.contents = NSColor.redColor()
                } else {
                    sphereGeometry.firstMaterial?.diffuse.contents = NSColor.greenColor()
                }
                
                let sphereNode = SCNNode(geometry: sphereGeometry)
                sphereNode.position = SCNVector3(x: x, y: y, z: z)
                
                
                cubeNode.addChildNode(sphereNode)
                
                x += 3 * CGFloat(radius)
                myIndex++
                
            }
            z += 3 * CGFloat(radius)
        }
        y += 3 * CGFloat(radius)
    }
    
    cubeNode.runAction(SCNAction.rotateByX(0, y: -0.3, z: 0, duration: 0.0))
    self.rootNode.addChildNode(cubeNode)
    
  }
    
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
