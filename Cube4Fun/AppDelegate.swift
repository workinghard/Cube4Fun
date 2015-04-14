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
var __animations: Animations = Animations()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var animationsWindow: NSWindow!
    @IBOutlet weak var preferencesWindow: NSWindow!
    @IBOutlet weak var myMenu: NSMenu!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        _animationsWindow = animationsWindow
        _cubeWindow = window
        //__animations.initialize()
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
    
}
