//
//  AppDelegate.swift
//  Cube4Fun
//
//  Created by Nikolai Rinas on 27.03.15.
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

import Cocoa

var _animationsWindow: NSWindow = NSWindow()
var _cubeWindow: NSWindow = NSWindow()
var _prefWindow: NSWindow = NSWindow()
var __animations: Animations = Animations()
var __prefData: Preferences = Preferences()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var animationsWindow: NSWindow!
    @IBOutlet weak var preferencesWindow: NSWindow!
    @IBOutlet weak var myMenu: NSMenu!
    
    @IBOutlet weak var levelInd: NSProgressIndicator!
    @IBOutlet weak var ipAddr: NSTextField!
    @IBOutlet weak var port: NSTextField!
    @IBOutlet weak var waitAnim: NSProgressIndicator!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        _animationsWindow = animationsWindow
        _cubeWindow = window
        _prefWindow = preferencesWindow
        //__animations.initialize()
        
        port.stringValue = String(__prefData.portNR())
        ipAddr.stringValue = __prefData.ipAddr()
        if CubeNetworkObj.connected() {
            showConnActive(true)
        }else{
            showConnActive(false)
        }
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        CubeNetworkObj.closeConnection()
        return NSApplicationTerminateReply.TerminateNow
    }
    
    @IBAction func saveDocument(sender: AnyObject) {
        let mySavePanel: NSSavePanel = NSSavePanel()
        mySavePanel.allowedFileTypes = ["plist"]
        mySavePanel.beginWithCompletionHandler { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let exportedFileURL = mySavePanel.URL
                // Save the data. What you do depends on your app.
                let myAnimArray: NSMutableArray = NSMutableArray()
                myAnimArray.addObjectsFromArray(__animations.getAnimations())
                myAnimArray.writeToURL(exportedFileURL!, atomically: true)
                //let myAnimation: NSDictionary = NSDictionary(dictionary: __animations.getAnimations())
                
               
                // Don't just paste this code in your app as your app
                // probably doesn't have a createPDF() method.  self.createPDF(exportedFileURL)
            }
        } // End block
        print("save pressed")
    }
    
    @IBAction func openDocument(sender: AnyObject) {
        let myOpenPanel: NSOpenPanel = NSOpenPanel()
        myOpenPanel.allowedFileTypes = ["plist"]
        myOpenPanel.beginWithCompletionHandler { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let importedFileURL = myOpenPanel.URL
                //let myAnimationsDict: NSMutableDictionary = NSMutableDictionary(contentsOfURL: importedFileURL!)!
                let myAnimArray: NSMutableArray = NSMutableArray(contentsOfURL: importedFileURL!)!
                __animations.loadAnimations(myAnimArray)
            }
        } // End block
    }
    
    @IBAction func openPreferences(send: AnyObject) {
        preferencesWindow.setIsVisible(true)
    }
    
    @IBAction func testIPConnection(send: AnyObject) {
        //println("TestIP Button clicked")
        
        if CubeNetworkObj.connected() {
            CubeNetworkObj.closeConnection()
        }
        if CubeNetworkObj.openConnection(__prefData.ipAddr(), port: UInt32(__prefData.portNR())) {
            showConnActive(true)
        }else{
            showConnActive(false)
        }

    }
    
    func showConnActive(active: Bool) {
        if active {
            levelInd.doubleValue = 100.0
        }else{
            levelInd.doubleValue = 0.0
        }
    }
    
    func validIPAddress(ipaddr: String) -> Bool {
        var valid: Bool = false
        let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
        if ipaddr != "" {
            if (ipaddr.rangeOfString(validIpAddressRegex, options: .RegularExpressionSearch) != nil) {
                valid = true;
            }
        }
        return valid
    }
    
    func validPortNr(portNr: Int) -> Bool {
        var valid: Bool = false
        if portNr < 65536 && portNr > 0 {
            valid = true
        }
        return valid
        //^(6553[0-5]|655[0-2]\d|65[0-4]\d\d|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3}|0)$
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        let myField: NSTextField = obj.object as! NSTextField
        if myField.identifier == "IPADDR_FIELD" {
            if validIPAddress(myField.stringValue) {
                __prefData.setIPAddr(myField.stringValue)
                print("Changing ip address field")
            }
        }
        if myField.identifier == "PORTNR_FIELD" {
            if validPortNr(myField.integerValue) {
                __prefData.setPortNr(myField.integerValue)
                print("Changing port number")
            }
        }
    }
    
    @IBAction func cmdCopyPressed(send: AnyObject) {
        __animations.copyDisplayedFrame()
    }
    
    @IBAction func cmdPastePressed(send: AnyObject) {
        __animations.pasteDisplayedFrame()
        _gameView.updateLEDFrame()
        // Send updated frame
        __animations.sendFrame()
    }
    
    @IBAction func clearLEDs(send: AnyObject) {
        // Remove from Memory
        __animations.clearLEDColor()
        // Update visual
        _gameView.updateLEDFrame()
        // Update on a hardware
        __animations.sendFrame()
    }
    
    @IBAction func cmdInsertPressed(send: AnyObject) {
        // Insert one new frame at the current position
        __animations.insertDisplFrame()
        // Update visual
        _gameView.updateLEDFrame()
        _gameView.updateButtonVisibility()
        
        // Update on a hardware
        __animations.sendFrame()
    }
    
    @IBAction func cmdDeletePressed(send: AnyObject) {
        // Check if we have more than one frame
        if __animations.getAnimationFrameCount() > 1 {
            __animations.deleteDisplFrame()
            
            // Update visual
            _gameView.updateLEDFrame()
            _gameView.updateButtonVisibility()
            
            // Update on a hardware
            __animations.sendFrame()
        }
    }
}
