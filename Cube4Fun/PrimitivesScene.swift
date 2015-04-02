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

let debugOn = false
let animRun = false

class PrimitivesScene: SCNScene {
    
    func createPlayback() {
        // Play - Button
        let playImage = SCNPlane(width: 2.2, height: 2.2)
        playImage.firstMaterial?.diffuse.contents = NSImage(named: "media-playback-start-5.png")
        let playImageNode = SCNNode(geometry: playImage)
        playImageNode.name = "myPlayButton"
        playImageNode.position = SCNVector3(x:0, y:14, z:0)
        self.rootNode.addChildNode(playImageNode)
        
        // Pause - Button
        let pauseImage = SCNPlane(width: 2.5, height: 2.5)
        pauseImage.firstMaterial?.diffuse.contents = NSImage(named: "media-playback-pause-5.png")
        let pauseImageNode = SCNNode(geometry: pauseImage)
        pauseImageNode.name = "myPauseButton"
        pauseImageNode.position = SCNVector3(x:0, y:14, z:0)
        pauseImageNode.hidden = true
        if myFrameCount == 1 && myMaxFrameCount == 1 {
            pauseImageNode.hidden = true
        }
        self.rootNode.addChildNode(pauseImageNode)
        
        // NextFrame - Button
        let nextFrameImage = SCNPlane(width: 2.0, height: 2.0)
        nextFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "media-seek-forward-5.png")
        let nextFrameImageNode = SCNNode(geometry: nextFrameImage)
        nextFrameImageNode.name = "myNextFrameButton"
        nextFrameImageNode.position = SCNVector3(x:2, y:14, z:0)
        if myFrameCount == 1 && myMaxFrameCount == 1 {
            nextFrameImageNode.hidden = true
        }
        self.rootNode.addChildNode(nextFrameImageNode)
        
        // PrevFrame - Button
        let prevFrameImage = SCNPlane(width: 2.0, height: 2.0)
        prevFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "media-seek-backward-5.png")
        let prevFrameImageNode = SCNNode(geometry: prevFrameImage)
        prevFrameImageNode.name = "myPrevFrameButton"
        prevFrameImageNode.position = SCNVector3(x:-2, y:14, z:0)
        if myFrameCount == 1 {
            prevFrameImageNode.hidden = true
        }
        self.rootNode.addChildNode(prevFrameImageNode)
        
        // StartFrame - Button
        let startFrameImage = SCNPlane(width: 2.0, height: 2.0)
        startFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "media-skip-backward-5.png")
        let startFrameImageNode = SCNNode(geometry: startFrameImage)
        startFrameImageNode.name = "myStartFrameButton"
        startFrameImageNode.position = SCNVector3(x:-5, y:14, z:0)
        if myFrameCount == 1 {
            startFrameImageNode.hidden = true
        }
        self.rootNode.addChildNode(startFrameImageNode)
        
        // LastFrame - Button
        let lastFrameImage = SCNPlane(width: 2.0, height: 2.0)
        lastFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "media-skip-forward-5.png")
        let lastFrameImageNode = SCNNode(geometry: lastFrameImage)
        lastFrameImageNode.name = "myLastFrameButton"
        lastFrameImageNode.position = SCNVector3(x:5, y:14, z:0)
        if myFrameCount == myMaxFrameCount {
            lastFrameImageNode.hidden = true
        }
        self.rootNode.addChildNode(lastFrameImageNode)
        
        // AddFrame - Button
        let addFrameImage = SCNPlane(width: 1.7, height: 1.7)
        addFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "list-add-2.png")
        let addFrameImageNode = SCNNode(geometry: addFrameImage)
        addFrameImageNode.name = "myAddFrameButton"
        addFrameImageNode.position = SCNVector3(x:-16.5, y:12, z:0)
        self.rootNode.addChildNode(addFrameImageNode)
        
        // DeleteFrame - Button
        let delFrameImage = SCNPlane(width: 1.7, height: 1.7)
        delFrameImage.firstMaterial?.diffuse.contents = NSImage(named: "list-remove-2.png")
        let delFrameImageNode = SCNNode(geometry: delFrameImage)
        delFrameImageNode.name = "myDelFrameButton"
        delFrameImageNode.position = SCNVector3(x:-18.7, y:12, z:0)
        // for first frame, there is nothing to delete
        if ( myFrameCount == 1 ) {
            delFrameImageNode.hidden = true
        }
        self.rootNode.addChildNode(delFrameImageNode)
        
    }
    
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
    
    
    // ID for the LED
    let text = SCNText(string: "Klick", extrusionDepth: 0)
    text.font = NSFont(name: "Arial", size: 1.5)
    let textNode = SCNNode(geometry: text)
    textNode.name = "myDescr"
    if ( debugOn ) {
      textNode.position = SCNVector3(x:-20.0 , y: -14.0, z: 0.0)
    }else{
        textNode.position = SCNVector3(x:-20.0 , y: -24.0, z: 0.0)
    }
    self.rootNode.addChildNode(textNode)

    // Frame
    let textFrame = SCNText(string: "Frame: \(myFrameCount)/\(myMaxFrameCount)", extrusionDepth: 0)
    textFrame.font = NSFont(name: "Arial", size: 1.2)
    let textFrameNode = SCNNode(geometry: textFrame)
    textFrameNode.name = "myFrameText"
    textFrameNode.position = SCNVector3(x:-20.0 , y: 13.7, z: 0.0)
    self.rootNode.addChildNode(textFrameNode)
    
    
    // Action Buttons
    createPlayback()
    
    // color picker
    let colorBar = SCNPlane(width: 3, height: 16)
    colorBar.firstMaterial?.diffuse.contents = NSImage(named: "Gradient2.png")
    let colorBarNode = SCNNode(geometry: colorBar)
    colorBarNode.name = "myColorBar"
    colorBarNode.position = SCNVector3(x: 17, y: 7, z:0.0)
    self.rootNode.addChildNode(colorBarNode)
    
    // Arrows
    let arrowImage = SCNPlane(width: 3, height: 2.0)
    arrowImage.firstMaterial?.diffuse.contents = NSImage(named: "Arrows.png")
    let arrowImageNode = SCNNode(geometry: arrowImage)
    arrowImageNode.name = "myArrows"
    arrowImageNode.position = SCNVector3(x:17, y:15, z:0.1)
    self.rootNode.addChildNode(arrowImageNode)
    
    
    // All movable objects
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
                sphereNode.name = myIndex.description
                
                
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
