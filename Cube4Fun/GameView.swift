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
var klickedColor: Byte = Byte(1)
let relativeBarPosition: CGFloat = 500.0


class GameView: SCNView {
    
    func updateButtonVisibility() {
        // init
        var nextFrame = false;
        var lastFrame = false;
        var prevFrame = false;
        var firstFrame = false;
        var delFrame = false;
        
        // first Frame, only one Frame
        // -> no button visible
        if myFrameCount == 1 && myMaxFrameCount == 1 {
            nextFrame = false;
            lastFrame = false;
            prevFrame = false;
            firstFrame = false;
            delFrame = false;
        }
        
        // first Frame, second exists.
        if myFrameCount == 1 && myMaxFrameCount > 1 {
            // Visible:
            nextFrame = true;
            lastFrame = true;
            delFrame = true;
            // Invisible:
            prevFrame = false;
            firstFrame = false;
        }
        
        // previous Frame exists, no more Frames
        if myFrameCount > 1 && myFrameCount == myMaxFrameCount {
            // Visible:
            prevFrame = true;
            firstFrame = true;
            delFrame = true;
            // Invisible
            nextFrame = false;
            lastFrame = false;
        }
        
        // previous Frame exists and next Frame exists {
        if myFrameCount > 1 && myFrameCount < myMaxFrameCount {
            // Visible:
            prevFrame = true;
            firstFrame = true;
            delFrame = true;
            nextFrame = true;
            lastFrame = true;
        }
        
        if let rootNode = self.scene?.rootNode {
            for childNode in rootNode.childNodes {
                let buttonNode: SCNNode = childNode as SCNNode
                if buttonNode.name == "myNextFrameButton" {
                    buttonNode.hidden = !nextFrame;
                }
                if buttonNode.name == "myPrevFrameButton" {
                    buttonNode.hidden = !prevFrame
                }
                if buttonNode.name == "myStartFrameButton" {
                    buttonNode.hidden = !firstFrame
                }
                if buttonNode.name == "myLastFrameButton" {
                    buttonNode.hidden = !lastFrame
                }
                if buttonNode.name == "myDelFrameButton" {
                    buttonNode.hidden = !delFrame
                }
                if buttonNode.name == "myFrameText" {
                    let geometry:SCNText = buttonNode.geometry as SCNText
                    geometry.string = "Frame: \(myFrameCount)/\(myMaxFrameCount)"
                }
                
            }
        }

    }
    
    func updateLEDFrame() {
        // get actuall frame data
        
        let data : UnsafePointer<Byte> = UnsafePointer<Byte>(myFrames.mutableBytes)
        //NSMutableData
        if let rootNode = self.scene?.rootNode {
            if let cubeNode = rootNode.childNodeWithName("cubeNode", recursively: true) {
                for myLED in cubeNode.childNodes {
                    if let name:NSString = myLED.name {
                        if name != "myBox"  { // LED lamps
                            if let geometry: SCNGeometry = myLED.geometry {
                                let ledID: Int = Int(name.integerValue)
                                if let material: SCNMaterial = geometry.firstMaterial {
                                    var color: NSColor = NSColor()
                                    let colorPosition: Int = ((myFrameCount-1)*64) + ledID
                                    let savedColor: Byte = data[colorPosition]
                                    if data[colorPosition] == 255 {
                                        color = NSColor.grayColor()
                                    }else{
                                        let hueColor = CGFloat(savedColor) / 255.0
                                        color = NSColor(calibratedHue: hueColor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                                    }
                                    material.diffuse.contents = color
                                    //println(name)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func plusButtonPressed() {
        // Extend the data array with one frame
        myFrames.appendBytes(emptyFrame, length: 64)
        
        // Add frame
        myMaxFrameCount++;

        // Goto new frame
        myFrameCount = myMaxFrameCount;
        
        // Update LEDs
        updateLEDFrame()
        
        // Update control button visibility
        updateButtonVisibility()
    }

    func minusButtonPressed() {
        // remove one frame from the data array
        // TODO!
        
        // Remove frame
        if myMaxFrameCount > 1 {
            myMaxFrameCount--;
        }
        if myFrameCount > 1 {
            myFrameCount--;
        }
        
        // Update control button visibility
        updateButtonVisibility()
    }

    func prevButtonPressed() {
        if myFrameCount > 1 {
            myFrameCount--
        }
        // Update LEDs
        updateLEDFrame()
        
        // Update control button visibility
        updateButtonVisibility()
    }
    
    func nextButtonPressed() {
        if myFrameCount < myMaxFrameCount {
            myFrameCount++
        }
        
        // Update LEDs
        updateLEDFrame()
        
        // Update control button visibility
        updateButtonVisibility()
    }
    
    func firstButtonPressed() {
        myFrameCount = 1;
        
        // Update LEDs
        updateLEDFrame()
        
        // Update control button visibility
        updateButtonVisibility()
    }
    
    func lastButtonPressed() {
        myFrameCount = myMaxFrameCount
        
        // Update LEDs
        updateLEDFrame()
        
        // Update control button visibility
        updateButtonVisibility()
    }
    
    func playButtonPressed() {
        // Change the button from Play to Pause
        let myPauseButtonNode: SCNNode = self.scene!.rootNode.childNodeWithName("myPauseButton", recursively: true)!
        let myPlayButtonNode: SCNNode = self.scene!.rootNode.childNodeWithName("myPlayButton", recursively: true)!
        myPlayButtonNode.hidden = true
        myPauseButtonNode.hidden = false

        // Start the animation
        _playAllFrames = true
    }
    
    func pauseButtonPressed() {
         // Change the button from Pause to Play
        let myPauseButtonNode: SCNNode = self.scene!.rootNode.childNodeWithName("myPauseButton", recursively: true)!
        let myPlayButtonNode: SCNNode = self.scene!.rootNode.childNodeWithName("myPlayButton", recursively: true)!   
        myPauseButtonNode.hidden = true
        myPlayButtonNode.hidden = false
    
        // Stop the animation
        _playAllFrames = false
    }
    
    
    override func rightMouseDown(theEvent: NSEvent) {
        let p = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        if let hitResults = self.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                if let node = result.node {
                    if let geom = node.geometry {
                        if let name:NSString = geom.name {
                            if name.integerValue >= 0 && name.integerValue < 64  { // LED lamps
                                let color: NSColor = geom.firstMaterial?.diffuse.contents as NSColor
                                if color != NSColor.grayColor() {
                                    // Make sure we are in range of 0...255
                                    let ledColor = (color.hueComponent * 255) % 255
                                    if ( ledColor >= 0 && ledColor < 255 ) {
                                        klickedColor = Byte(ledColor)
                                    }
                                    klickedColor = Byte (color.hueComponent * 255)
                                    moveArrows(Int(klickedColor))
                                    //println(klickedColor)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
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
                
                if let clickedNode = result.node {
                    if clickedNode.name == "myBox" {
                        anim = false
                    }
                    if clickedNode.name == "myPlayButton" && myMaxFrameCount > 1 {
                        playButtonPressed()
                        anim = false
                    }
                    if clickedNode.name == "myPauseButton" {
                        pauseButtonPressed()
                        anim = false
                    }
                    if clickedNode.name == "myAddFrameButton" {
                        plusButtonPressed()
                    }
                    if clickedNode.name == "myDelFrameButton" {
                        minusButtonPressed()
                    }
                    if clickedNode.name == "myPrevFrameButton" {
                        prevButtonPressed()
                    }
                    if clickedNode.name == "myNextFrameButton" {
                        nextButtonPressed()
                    }
                    if clickedNode.name == "myStartFrameButton" {
                        firstButtonPressed()
                    }
                    if clickedNode.name == "myLastFrameButton" {
                        lastButtonPressed()
                    }
                     if clickedNode.name == "myColorBar" || clickedNode.name == "myArrows" {
                        let colorInt = Int(round(relativeBarPosition - theEvent.locationInWindow.y))
                        if colorInt < 0 {
                            klickedColor = 0 // Minimum value
                        }else{
                            if colorInt > 253 {
                                klickedColor = 253 // Maximum value
                            }else{
                                klickedColor = Byte(colorInt)
                                println(klickedColor)
                            }
                        }
                        // Move arrows to the clicked position
                        moveArrows(colorInt)
                        
                        //println("BarX: \(barRootPositionX) ClickedX: \(theEvent.locationInWindow.x) ")
                        //println("BarY: \(barRootPositionY) ClickedY: \(theEvent.locationInWindow.y) ")

                        
                        anim = false
                    }
                }
                
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
                                let hueColor = CGFloat(klickedColor) / 255.0
                                geom.firstMaterial?.diffuse.contents = NSColor(calibratedHue: hueColor, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                                ledColorOn = true
                            }
                            ledPressed = Int(name.intValue)
                            
                        }
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
                    SCNTransaction.setAnimationDuration(0.2)
                
                    // on completion - unhighlight
                    SCNTransaction.setCompletionBlock() {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.2)
                    
                    material.emission.contents = NSColor.blackColor()
                    
                    SCNTransaction.commit()
                    }
                
                    material.emission.contents = NSColor.grayColor()
                
                    SCNTransaction.commit()
                    
                    // Update the LED frame
                    var myByte: [Byte]
                    if ledColorOn {
                        myByte = [klickedColor]
                    }else{
                        myByte = [255]  // Off
                    }
                    myFrames.replaceBytesInRange(NSMakeRange(((myFrameCount-1)*64)+ledPressed, 1), withBytes: myByte)
                    
                }

            }
        }
        
        super.mouseDown(theEvent)
    }

    func moveArrows(colorY: Int) {
        // Range is from y=+15 ... -1
        let myArrowsNode = self.scene!.rootNode.childNodeWithName("myArrows", recursively: true)
        let myRelativePos = 16.0 * CGFloat(colorY) / 255.0
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.5)
        myArrowsNode?.position = SCNVector3(x:17, y: (16 - myRelativePos)-1, z:0.1)
        SCNTransaction.commit()
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
                        if let name:NSString = myLED.name {
                            if name != "myBox"  { // LED lamps
                                if let geometry: SCNGeometry = myLED.geometry {
                                    if let material: SCNMaterial = geometry.firstMaterial {
                                        material.diffuse.contents = NSColor.grayColor()
                                        //println(name)
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            break;
        default:
            super.keyDown(theEvent)
        }
        
        println(theEvent.keyCode);
        
        
        //super.keyDown(theEvent)
    }
    
}
