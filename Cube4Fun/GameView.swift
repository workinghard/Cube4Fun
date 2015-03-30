//
//  GameView.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import SceneKit

var lastMousePos: NSPoint = NSPoint()
var startAngle: CGFloat = CGFloat()

class GameView: SCNView {
    
    //var lastMousePos: NSPoint
    
    override func mouseDown(theEvent: NSEvent) {
        lastMousePos = theEvent.locationInWindow
        /* Called when a mouse click occurs */
        
        var ledPressed: Int = 0;
        var ledColorOn = false;
        
        // check what nodes are clicked
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let hitResults = self.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                var anim = true
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // get its name
                if let node = result.node {
                    if let geom = node.geometry {
                        if let name:NSString = geom.name {
                            let myGeometry:SCNText = self.scene!.rootNode.childNodeWithName("myDescr", recursively: true)?.geometry as SCNText
                            // Show touched led
                            myGeometry.string = name
                            // Check for previously color
                            let prevColor = geom.firstMaterial?.diffuse.contents as NSColor
                            if prevColor != NSColor.grayColor() {
                                geom.firstMaterial?.diffuse.contents  = NSColor.grayColor()
                                ledColorOn = false
                            }else{
                                geom.firstMaterial?.diffuse.contents = NSColor(calibratedHue: (10/255), saturation: 1.0, brightness: 1.0, alpha: 1.0)
                                ledColorOn = true
                            }
                            ledPressed = Int(name.intValue)
                            
                        }
                    }
                }

                if let boxNode = result.node {
                    if boxNode.name == "myBox" {
                        anim = false
                    }
                }

                /*
                if let rootNode = self.scene?.rootNode {
                    if let cubeNode = rootNode.childNodeWithName("cubeNode", recursively: true) {
                        if let boxNode = cubeNode.childNodeWithName("myBox", recursively: true ) {
                            //anim = false
                        }
                    }
                } */

                
                //let name:NSString = result.node!.geometry!.name!
/*
                let myScene:SCNScene = self.scene!
                let myRootNode:SCNNode = myScene.rootNode
                let myTextNode:SCNNode = myRootNode.childNodeWithName("myDescr", recursively: false)!
                let myGeometry:SCNText = myTextNode.geometry as SCNText
*/

                
                
                //let nextNode = self.scene
                //let text = self.scene?.rootNode.childNodeWithName("myDescr", recursively: true)
               

                //println(name);
                
                if anim {
                
                    // highlight it
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                
                    // on completion - unhighlight
                    SCNTransaction.setCompletionBlock() {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = NSColor.blackColor()
                    
                    SCNTransaction.commit()
                    }
                
                    material.emission.contents = NSColor.whiteColor()
                
                    SCNTransaction.commit()
                    
                    // Update the LED frame
                    var myByte: [Byte]
                    if ledColorOn {
                        myByte = [10]
                    }else{
                        myByte = [255]  // Off
                    }
                    myFrames.replaceBytesInRange(NSMakeRange(ledPressed, 1), withBytes: myByte)
                    
                }
            }
        }
        
        super.mouseDown(theEvent)
    }

    func rotateCamera(var x: CGFloat, var y: CGFloat) {
        // Save the angle for reset
        startAngle = startAngle + y
        
        // rotate
        if let node = self.scene!.rootNode.childNodeWithName("cubeNode", recursively: true) {
            node.runAction(SCNAction.rotateByX(0, y: y, z: 0, duration: 0.5))
        }
        //println(startAngle)
    }

    override func mouseUp(theEvent: NSEvent) {
        // Reset the last location
        lastMousePos.x = 0.0
        lastMousePos.y = 0.0
        
        super.mouseUp(theEvent)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        let mousePos = theEvent.locationInWindow
        if lastMousePos.x > 0.0 {
            let drag = ( (lastMousePos.x - mousePos.x ) / 50 ) * -1
            rotateCamera(0.0, y: drag)
            lastMousePos = mousePos
            //println(drag)
        }
        
        super.mouseDragged(theEvent)
    }
    
    override func keyDown(theEvent: NSEvent) {

        switch (theEvent.keyCode) {
        case 123:
            self.rotateCamera(0.0, y: -0.1)
          // Left
            break;
        case 124:
            self.rotateCamera(0.0, y: 0.1)
            //self.rotateByAngle(-1.0);
            //right
            break;
        case 15: // r - Key
            // Reset the cube position
            self.rotateCamera(0.0, y: -startAngle)
            break;
        case 17: // t - Key
            // Reset the frame color on the Cube
            myFrames.replaceBytesInRange(NSMakeRange(myFrameCount-1, 64), withBytes: emptyFrame)
            
            // Reset the frame color in 3D
            if let rootNode = self.scene?.rootNode {
                if let cubeNode = rootNode.childNodeWithName("cubeNode", recursively: true) {
                    for myLED in cubeNode.childNodes {
                        //myLED.firstMaterial?.diffuse.contents  = NSColor.grayColor()
                    }
                }
            }
        default:
            super.keyDown(theEvent)
        }
        
        println(theEvent.keyCode);
        
        
        //super.keyDown(theEvent)
    }
    
}
