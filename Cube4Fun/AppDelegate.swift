//
//  AppDelegate.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

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
        println("save pressed")
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
                println("Changing ip address field")
            }
        }
        if myField.identifier == "PORTNR_FIELD" {
            if validPortNr(myField.integerValue) {
                __prefData.setPortNr(myField.integerValue)
                println("Changing port number")
            }
        }
    }
    
    @IBAction func cmdCopyPressed(send: AnyObject) {
        println("cmd c pressed")
    }
    
    @IBAction func cmdPastePressed(send: AnyObject) {
        println("cmd v pressed")
    }
    
}
