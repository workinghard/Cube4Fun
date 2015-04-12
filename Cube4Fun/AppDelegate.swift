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
    
    
}
