//
//  ProjectController.swift
//  Cube4Fun
//
//  Created by Nikolai Rinas on 02.04.15.
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
import Foundation

//let _emptyAnimation: NSMutableDictionary = ["AnimName": "Animation1", "AnimKey": "1=anim1", "AnimDur": 1, "AnimSpeed": 500, "AnimFrames": 1]

/*
var dataArray: [NSMutableDictionary] = [["AnimName": "Animation1", "AnimKey": "1=anim1", "AnimDur": 3, "AnimSpeed": 700, "AnimFrames": 12],
    ["AnimName": "Animation2", "AnimKey": "1=anim2", "AnimDur": 7, "AnimSpeed": 1700, "AnimFrames": 17],
    ["AnimName": "Animation3", "AnimKey": "1=anim3", "AnimDur": 1, "AnimSpeed": 500, "AnimFrames": 22],
    ["AnimName": "Animation4", "AnimKey": "1=anim4", "AnimDur": 10, "AnimSpeed": 500, "AnimFrames": 32],
    ["AnimName": "Animation5", "AnimKey": "1=anim5", "AnimDur": 23, "AnimSpeed": 500, "AnimFrames": 18],
    ["AnimName": "Animation6", "AnimKey": "1=anim6", "AnimDur": 2, "AnimSpeed": 1000, "AnimFrames": 52]];
*/

//var _animationArray: [NSMutableDictionary] = [NSMutableDictionary]();
//var _selectedAnimation: Int = 0;

var __tableView: NSTableView = NSTableView()

class AnimationsController: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var myTableView: NSTableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        __tableView = myTableView
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let numberOfRows:Int = __animations.count() // _animationArray.count
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        //let object: NSDictionary = __animations.getAnimation(row) //_animationArray[row] as NSDictionary
        //println(object)
        let column: String = tableColumn?.identifier as String!
        if  column == "AnimName" {
            return __animations.getAnimationName(row)
            //let value = object.objectForKey(column) as String
            //return value
        }
        if column == "AnimKey" {
            return __animations.getAnimationKey(row)
            //let value = object.objectForKey(column) as String
            //return value
        }
        if column == "AnimDur" {
            return __animations.getAnimationDuration(row)
            //let value = object.objectForKey(column) as Int
            //return value
        }
        if column == "AnimSpeed" {
            return __animations.getAnimationSpeed(row)
            //let value = object.objectForKey(column) as Int
            //return value
        }
        if column == "AnimFrames" {
            return __animations.getAnimationFrameCount(row)
            //let value = object.objectForKey(column) as Int
            //return value
        }

        return column
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let view: NSTableView = notification.object as! NSTableView
        println("klicked \(view.selectedRow)")
        __animations.setSelectedAnimationID(view.selectedRow)
       
        _gameView.resetView()
        //let myCubeController: GameViewController = _animationsWindow.contentViewController as! GameViewController
        //let myCubeView: GameView = myCubeController.view as! GameView
        //myCubeView.resetView()
        
        //_selectedAnimation = view.selectedRow
        
        println("klicked \(view.selectedRow)")
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        let column: String = tableColumn?.identifier as String!
        //println("Object: \(object) Key: \((tableColumn?.identifier)!)" )

        let value = object! as! NSString
        if  column == "AnimName" {
            __animations.setAnimationName(row, value: value as String)
            //_animationArray[row].setObject(value, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimKey" {
            __animations.setAnimationKey(row, value: value as String)
            //_animationArray[row].setObject(value, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimDur" {
            __animations.setAnimationDuration(row, value: value.integerValue)
            //_animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimSpeed" {
            __animations.setAnimationSpeed(row, value: value.integerValue)
            //_animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        }
        
        _gameView.resetView()
        
        //if column == "AnimFrames" {
        //    _animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        //}
    }
    
    @IBAction func addNewAnimation(sender: AnyObject) {
        __animations.addAnimation()
        myTableView.reloadData()
    }
    
    @IBAction func delNewAnimation(sender: AnyObject) {
        __animations.deleteSelected()
        myTableView.selectRowIndexes(NSIndexSet(index: __animations.getSelectedAnimationID()-1), byExtendingSelection: false)
        myTableView.reloadData()
    }
    
    @IBAction func moveUpItem(send: AnyObject) {
        if ( __animations.getSelectedAnimationID() > 0 ) {
            __animations.moveUpSelected()
            myTableView.reloadData()
            myTableView.selectRowIndexes(NSIndexSet(index: __animations.getSelectedAnimationID()-1), byExtendingSelection: false)
        }
    }
    
    @IBAction func moveDownItem(send: AnyObject) {
        if (__animations.getSelectedAnimationID() < __animations.count() - 1) {
            __animations.moveDownSelected()
            myTableView.reloadData()
            myTableView.selectRowIndexes(NSIndexSet(index: __animations.getSelectedAnimationID()+1), byExtendingSelection: false)
        }
    }
    
    func convertInt16(value: UInt16) -> ([UInt8]) {
        var array: [UInt8] = [0,0]
        array[0] = UInt8(value & 0x000000ff);
        array[1] = UInt8((value & 0x0000ff00) >> 8);
        return array;
    }
    
    func convertInt32(value: UInt32) -> ([UInt8]) {
        var array: [UInt8] = [0,0,0,0]
        array[0] = UInt8(value & 0x000000ff);
        array[1] = UInt8((value & 0x0000ff00) >> 8);
        array[2] = UInt8((value & 0x00ff0000) >> 16);
        array[3] = UInt8((value & 0xff000000) >> 24);
        return array;
    }
    
    @IBAction func exportAnimations(send: AnyObject) {
        var sendData: [UInt8] = [UInt8]()
        println("Import button pressed")
        
        // for each animation
        for ( var i = 0; i < __animations.count(); ++i ) {
            // Create header line per animation
            // Syntax: ,F<key:12Byte>,<playtime:2Byte><speed:2Byte><frames:2Byte>\n
            
            // Key
            sendData.append(UInt8(ascii: ","))
            sendData.append(UInt8(ascii: "F"))
            let key = __animations.getAnimationKey(i)
            let keyArray: NSData = key.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
            let keyBytes: UnsafePointer<UInt8> = UnsafePointer<UInt8>(keyArray.bytes)
            for (var j = 0; j < keyArray.length; ++j) {
                
                if  keyBytes[j] != UInt8(ascii: "\n") && keyBytes[j] != UInt8(ascii: "\r" )  { // ignore line breaks in the key
                    sendData.append(UInt8(keyBytes[j]))
                }
            }
            sendData.append(UInt8(ascii: ","))
            
            // Playtime
            let playTime: [UInt8] = convertInt16(UInt16(__animations.getAnimationDuration(i)))
            sendData.append(playTime[0])
            sendData.append(playTime[1])

            // Speed
            let playSpeed: [UInt8] = convertInt16(UInt16(__animations.getAnimationSpeed(i)))
            sendData.append(playSpeed[0])
            sendData.append(playSpeed[1])
            
            // Frames
            let playFrames: [UInt8] = convertInt16(UInt16(__animations.getAnimationFrameCount(i)))
            sendData.append(playFrames[0])
            sendData.append(playFrames[1])
            
            // End line
            sendData.append(UInt8(ascii: "\n"))

            // Append frame, separated by new-Line
            let animData = __animations.getAnimData(i)
            for ( var count = 1; count <= __animations.getAnimDataLength(i); ++count) {
                sendData.append(animData[count-1])
                // End line for each frame
                if ( (count % 64) == 0 ) {
                    sendData.append(UInt8(ascii: "\n"))
                }
            }
            
            
        }
        
        
        // Calculate overall data to send
    
        
        // Send data
        CubeNetworkObj.sendBytes(sendData , count: UInt32(sendData.count))
        
    }
    
    /*
    @IBAction func closeButtonClicked(sender: AnyObject ) {
        animationsWindow.close()
    }
*/
}
