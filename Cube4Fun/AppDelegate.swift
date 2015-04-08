//
//  AppDelegate.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import Cocoa

var _animationsWindow: NSWindow = NSWindow()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var animationsWindow: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        _animationsWindow = animationsWindow
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        CubeNetworkObj.closeConnection()
        return NSApplicationTerminateReply.TerminateNow
    }
    
    
}
