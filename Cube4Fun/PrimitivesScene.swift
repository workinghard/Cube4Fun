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
    
    let spaceBetweenLEDs:CGFloat = 4.0
    let edgePosX:CGFloat = CGFloat(xCount-1) * spaceBetweenLEDs * -1 / 2
    let edgePosY:CGFloat = CGFloat(yCount-1) * spaceBetweenLEDs * -1 / 2
    let edgePosZ:CGFloat = CGFloat(zCount-1) * spaceBetweenLEDs * -1 / 2
    let boxSizeX:CGFloat = CGFloat(xCount-1) * spaceBetweenLEDs + 2 * radius
    let boxSizeZ:CGFloat = CGFloat(zCount-1) * spaceBetweenLEDs + 2 * radius
    let boxPosY:CGFloat = (CGFloat(yCount-1) * spaceBetweenLEDs / 2) + radius + 0.5
    
    let text = SCNText(string: "Klick", extrusionDepth: 1)
    let textNode = SCNNode(geometry: text)
    textNode.name = "myDescr"
    textNode.position = SCNVector3(x:-14.0 , y: 7.0, z: 0.0)
    textNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
    
    self.rootNode.addChildNode(textNode)
    
    
    let cubeNode = SCNNode()
    cubeNode.name = "cubeNode"
    
    let box = SCNBox(width: boxSizeX, height: 1.0, length: boxSizeZ, chamferRadius: 0.1)
    box.firstMaterial?.diffuse.contents = NSColor.whiteColor()
    let boxNode = SCNNode(geometry: box)
    boxNode.name = "myBox"
    boxNode.position = SCNVector3(x:0.0 , y: -boxPosY, z: 0.0)
    cubeNode.addChildNode(boxNode)


    var y:CGFloat = edgePosY
    for row in 0..<yCount {
        var z:CGFloat = edgePosZ
        for depth in 0..<zCount {
            var x:CGFloat = edgePosX
            for column in 0..<xCount {
                
                let sphereGeometry = SCNSphere(radius: radius)
                sphereGeometry.name = myIndex.description
                
                sphereGeometry.firstMaterial?.diffuse.contents = NSColor.grayColor()
                /*
                if (row % 2 == 0) {
                    sphereGeometry.firstMaterial?.diffuse.contents = NSColor.redColor()
                } else {
                    sphereGeometry.firstMaterial?.diffuse.contents = NSColor.greenColor()
                }*/
                
                let sphereNode = SCNNode(geometry: sphereGeometry)
                sphereNode.position = SCNVector3(x: y, y: x, z: z)
                
                
                cubeNode.addChildNode(sphereNode)
                
                x += spaceBetweenLEDs * CGFloat(radius)
                myIndex++
                
            }
            z += spaceBetweenLEDs * CGFloat(radius)
        }
        y += spaceBetweenLEDs * CGFloat(radius)
    }
    
    cubeNode.runAction(SCNAction.rotateByX(0, y: 0.6, z: 0, duration: 0.0))
    self.rootNode.addChildNode(cubeNode)
    
  }
    
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}
