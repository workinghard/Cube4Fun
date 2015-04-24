//
//  Animations.swift
//  Cube4Fun
//
//  Created by Nikolai Rinas on 07.04.15.
//  Copyright (c) 2015 Nikolai Rinas. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>


// Constants
let AnimName = "AnimName"
let AnimKey = "AnimKey"
let AnimDuration = "AnimDur"
let AnimSpeed = "AnimSpeed"
let AnimFrames = "AnimData"

class Animations: NSObject {
    
    let _emptyFrame: [UInt8] = [
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255,
        255,255,255,255]
    
    var _displayedFrame: Int = 1;
//    var _frameCount: UInt32 = 1;
//    var _oneFrame: NSMutableData = NSMutableData() // == byte[] array
//    var _emptyAnimation: NSMutableDictionary = NSMutableDictionary()
    var _animationArray: [NSMutableDictionary] = [NSMutableDictionary]()
    var _animationSelected: Int = 0
    let _minSendDelay: NSTimeInterval = 0.200 // fastes speed 200 milliseconds
    let maxFrameSpeed = 3000 // the lowest possible speed allowed
    let minFrameSpeed = 100 // the fastest possible speed allowed
    let frameSpeedStep = 100 // how fast increase or decrease speed
//    var _playSendDelay: NSTimeInterval = 0.5 // 500 milliseconds as default
    var _copyFrameBuffer: [UInt8] = [UInt8]()
    
    
    override init() {
        super.init()
        // Show the first frame
        _displayedFrame = 1
        // Append empty animation
        self.addAnimation()
        // Set visible animation
        _animationSelected = 0
        // Init Buffer
        for ( var i = 0; i < 64 ; ++i ) {
        _copyFrameBuffer.append(255)
        }
    }
    
    // How much animations do we have
    func count() -> (Int) {
        return _animationArray.count
    }
    
    func sendFrame() {
        let time = NSDate.timeIntervalSinceReferenceDate()
        
        if (_previousUpdateTime == 0.0) {
            _previousUpdateTime = time;
        }
        // need to do this because of rounding issues
        let deltaTime: Int = Int( round( (time - _previousUpdateTime) * 10 ) * 100);
        
        //var ms = Int((time % 1) * 1000)
        if ( _playAllFrames ) {
            //println("Delta: \(deltaTime) Speed: \(__animations.animationSpeedInt())")
            if ( deltaTime >= __animations.animationSpeedInt() ){
                _previousUpdateTime = time;
                if (self.getAnimationFrameID() >= self.getAnimationFrameCount()) {
                    _gameView.firstButtonPressed()
                }else{
                    _gameView.nextButtonPressed()
                }
                CubeNetworkObj.updateFrame(self.getAnimDataSelected(), count: UInt32(self.getAnimationFrameID()))
                
            }
        }else{
            CubeNetworkObj.updateFrame(self.getAnimDataSelected(), count: UInt32(self.getAnimationFrameID()))
        }
    }
    
    func loadAnimations(animArray: NSArray) {
        // clear the array first
        _animationArray.removeAll(keepCapacity: true)
        for ( var i=0; i<animArray.count; i++ ) {
            _animationArray.append(animArray[i] as! NSMutableDictionary)
            //println("append Animation count: \(_animationArray.count)")
        }
        self.setSelectedAnimationID(0)
        _gameView.resetView()
        __tableView.reloadData()
    }
    
    func getAnimation(id: Int) -> (NSDictionary) {
        //println(_animationArray.count)
        let myAnimation = _animationArray[id] as NSDictionary
        return myAnimation
    }
    func getAnimations() -> ([NSDictionary]) {
        return _animationArray as [NSDictionary];
    }
    
    func getAnimationName(id: Int) -> (String) {
        let value = (self.getAnimation(id)).objectForKey(AnimName) as! String
        return value
    }
    func setAnimationName(id: Int, value: String) {
        (self.getAnimation(id)).setValue(value, forKey: AnimName)
    }
    
    func getAnimationKey(id: Int) -> (String) {
        let value = (self.getAnimation(id)).objectForKey(AnimKey) as! String
        return value
    }
    func setAnimationKey(id: Int, value: String) {
        (self.getAnimation(id)).setValue(value, forKey: AnimKey)
    }
    
    func getAnimationDuration(id: Int) -> (Int) {
        let value = (self.getAnimation(id)).objectForKey(AnimDuration) as! Int
        return value
    }
    func setAnimationDuration(id: Int, value: Int) {
        (self.getAnimation(id)).setValue(value, forKey: AnimDuration)
    }
    
    func getAnimationSpeed(id: Int) -> (Int) {
        let value = (self.getAnimation(id)).objectForKey(AnimSpeed) as! Int
        return value
    }
    func setAnimationSpeed(id: Int, value: Int) {
        (self.getAnimation(id)).setValue(value, forKey: AnimSpeed)
    }
    
    func getAnimationFrameCount() -> (Int) {
        return self.getAnimationFrameCount(_animationSelected)
    }
    func getAnimationFrameCount(id: Int) -> (Int) {
        let myFrames: NSMutableData = (self.getAnimation(id)).objectForKey(AnimFrames) as! NSMutableData
        return (myFrames.length / 64)
        //let value = (self.getAnimation(id)).objectForKey("AnimFrames") as Int
        //return value
    }
    func getAnimationFrameID() -> Int {
        return _displayedFrame
    }
    func setAnimationFrameID(id: Int) {
        _displayedFrame = id
    }

    func setSelectedAnimationID(id: Int) {
        if id >= 0 {
            _animationSelected = id
            _displayedFrame = 1
        }
    }
    func getSelectedAnimationID() -> (Int) {
        return _animationSelected
    }
    func deleteSelected() {
        _animationArray.removeAtIndex(_animationSelected)
        if ( _animationSelected == 0 && _animationArray.count == 0 ) { // last Frame
            self.addAnimation()
        }
    }
    func moveUpSelected() {
        if ( _animationSelected > 0 ) {
            _animationArray.insert(_animationArray[_animationSelected], atIndex: _animationSelected-1)
            _animationArray.removeAtIndex(_animationSelected+1)
        }
    }
    func moveDownSelected() {
        if (_animationSelected < _animationArray.count - 1) {
            _animationArray.insert(_animationArray[_animationSelected+1], atIndex: _animationSelected)
            _animationArray.removeAtIndex(_animationSelected+2)
        }
    }
    
    func addAnimation() {
        _animationArray.append(self.newAnimation())
        println("append Animation count: \(_animationArray.count)")
    }
    func newAnimation() -> (NSMutableDictionary)  {
        println("create new animation")
        return [AnimName: "Animation1", AnimKey: "1=anim1", AnimDuration: 10, AnimSpeed: 500, AnimFrames: self.newFrame()]
    }
    func newFrame() -> (NSMutableData) {
        println("create new frame")
        return NSMutableData(bytes: _emptyFrame, length: 64)
    }
    func addFrame() {
        let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
        myData.appendBytes(_emptyFrame, length: 64)
    }
    func removeFrame() {
        if self.getAnimationFrameCount() > 1 {
            let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
            let myLength = myData.length
            myData.length = myLength - 64 // remove one frame
        }
    }
    func insertDisplFrame() {
        // Get Array
        let myData = self.getAnimDataSelected()
        // Get startPositions of the selected frame
        var frameStartPos = (self.getAnimationFrameID()-1)*64
        // Insert empty frame at this position
        for index in 0...64 {
            myData.insert(_emptyFrame[index], atIndex: frameStartPos)  
        } 
    }
    func deleteDisplFrame() {
        // Get Array
        let myData = self.getAnimDataSelected()
        // Get startPositions of the selected frame
        var frameStartPos = (self.getAnimationFrameID()-1)*64
        for index in 0...64 {
            myData.removeAtIndex(frameStartPos)  
        } 
    }
    
    func animationSpeedInt() -> Int {
        let frameSpeed: Int = (self.getAnimation(_animationSelected)).objectForKey(AnimSpeed) as! Int
        return frameSpeed
    }
    func animationSpeedFloat() -> NSTimeInterval {
        let frameSpeed: Int = (self.getAnimation(_animationSelected)).objectForKey(AnimSpeed) as! Int
        let mySpeed: NSTimeInterval = NSTimeInterval(Float(frameSpeed)/1000)
        return mySpeed
    }
    func increaseSpeed() {
        let frameSpeed: Int = (self.getAnimation(_animationSelected)).objectForKey(AnimSpeed) as! Int
        if frameSpeed < maxFrameSpeed {
            (self.getAnimation(_animationSelected)).setValue(frameSpeed+frameSpeedStep, forKey: AnimSpeed)
        }
    }
    func decreaseSpeed() {
        let frameSpeed: Int = (self.getAnimation(_animationSelected)).objectForKey(AnimSpeed) as! Int
        if frameSpeed > minFrameSpeed {
            (self.getAnimation(_animationSelected)).setValue(frameSpeed-frameSpeedStep, forKey: AnimSpeed)
        }
    }

    func gotoLastFrame() {
        self.setAnimationFrameID(self.getAnimationFrameCount())
    }
    func gotoFirstFrame() {
        self.setAnimationFrameID(1)
    }
    func gotoNextFrame() {
        if self.getAnimationFrameID() < self.getAnimationFrameCount() {
            self.setAnimationFrameID(self.getAnimationFrameID()+1)
        }
    }
    func gotoPrevFrame() {
        if self.getAnimationFrameID() > 1 {
            self.setAnimationFrameID(self.getAnimationFrameID()-1)
        }
    }

    
    func getMinSendDelay() -> (NSTimeInterval) {
        return _minSendDelay
    }
    
    func getAnimDataSelected() -> (UnsafePointer<UInt8>) {
        let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
        let byteArray = UnsafePointer<UInt8>(myData.bytes)
        return byteArray
    }
    
    func getAnimData(id: Int) -> (UnsafePointer<UInt8>) {
        let myData: NSMutableData = (self.getAnimation(id)).objectForKey(AnimFrames) as! NSMutableData
        let byteArray = UnsafePointer<UInt8>(myData.bytes)
        return byteArray
    }
    
    func getAnimDataLength(id: Int) -> Int {
        let myFrames: NSMutableData = (self.getAnimation(id)).objectForKey(AnimFrames) as! NSMutableData
        return myFrames.length
    }
    
    func setLEDColor(color: UInt8, led: Int) {
        //println("Led pressed: \(led)")
        var myByte: [UInt8] = [color]
        let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
        let bytePosition = NSMakeRange(((self.getAnimationFrameID()-1)*64)+led, 1)
        myData.replaceBytesInRange(bytePosition, withBytes: myByte)
        
        // Send updated frame
        self.sendFrame()
    }
    
    func getLEDColor(pos: Int) -> (UInt8) {
        let myData = self.getAnimDataSelected()
        return myData[pos]
    }
    
    func clearLEDColor() {
        //var myByte: [UInt8] = [255]
        let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
        myData.replaceBytesInRange(NSMakeRange((self.getAnimationFrameID()-1)*64, 64), withBytes: _emptyFrame)        
    }
    
    func copyDisplayedFrame() {
        let myData = self.getAnimDataSelected()
        var animFrameCount = (self.getAnimationFrameID()-1)*64
        for ( var i = 0 ; i < 64 ; ++i ) {
            _copyFrameBuffer[i] = myData[animFrameCount]
            ++animFrameCount
        }
    }
    func pasteDisplayedFrame() {
        let myData: NSMutableData = (self.getAnimation(_animationSelected)).objectForKey(AnimFrames) as! NSMutableData
        myData.replaceBytesInRange(NSMakeRange((self.getAnimationFrameID()-1)*64, 64), withBytes: _copyFrameBuffer)
    }
}
