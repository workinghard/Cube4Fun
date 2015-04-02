//
//  AppDelegate.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var projectWindow: NSWindow!
   
    
    @IBOutlet weak var closeButton: NSButton!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        CubeNetworkObj.closeConnection()
        return NSApplicationTerminateReply.TerminateNow
    }
    
    @IBAction func closeButtonClicked(sender: AnyObject ) {
        projectWindow.close()
    }
    
    
}
