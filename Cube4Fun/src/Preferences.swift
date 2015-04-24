//
//  Preferences.swift
//  Cube4Fun
//
//  Created by Nikolai Rinas on 18.04.15.
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