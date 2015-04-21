//
//  Preferences.swift
//  Cube4Fun
//
//  Created by Nik on 18.04.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import Foundation

class Preferences: NSObject {
    
    let _myPrefs: NSUserDefaults = NSUserDefaults()
    var _myIPAddr: String  = String()
    var _myPortNr: Int  = Int()
    
    let ipaddr_txt: String = "IPADDR"
    let portnr_txt: String = "PORTNR"
    // ipAddr
    
    
    override init() {
        super.init()
        
        // Load defaults
        self.loadFile()
    }
    
    func loadFile() {
        // Load ip address
        if let myIPAddr: String = _myPrefs.stringForKey(ipaddr_txt) {
            _myIPAddr = myIPAddr
        }
        // Load custom port
        let myPort: Int = _myPrefs.integerForKey(portnr_txt)
        if myPort > 0 {
            _myPortNr = myPort
        }
    }
    
    func saveFile() {
        // Save ip address
        _myPrefs.setObject(_myIPAddr, forKey: ipaddr_txt)
        // Save port number
        _myPrefs.setInteger(_myPortNr, forKey: portnr_txt)
    }
    
    func ipAddr() -> (String) {
        return _myIPAddr
    }
    
    func setIPAddr(ipAddr: String) {
        _myIPAddr = ipAddr
        self.saveFile()
    }
    
    func portNR() -> (Int) {
        return _myPortNr
    }
    
    func setPortNr(portNr: Int) {
        _myPortNr = portNr
        self.saveFile()
    }
}