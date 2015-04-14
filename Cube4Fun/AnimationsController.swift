//
//  ProjectController.swift
//  Cube4Fun
//
//  Created by Nik on 02.04.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

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
        __animations.setSelectedAnimationID(view.selectedRow)
       
        _gameView.resetView()
        //let myCubeController: GameViewController = _animationsWindow.contentViewController as! GameViewController
        //let myCubeView: GameView = myCubeController.view as! GameView
        //myCubeView.resetView()
        
        //_selectedAnimation = view.selectedRow
        
        //println("klicked \(view.selectedRow)")
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
        let testdata: [UInt8] = [254, 1, 128, 255]
        println("Import button pressed")
        
        // for each animation
        
        // Create header line per animation

        // Append frame, separated by new-Line
        
        // Calculate overall data to send
    
        
        // Send data
        CubeNetworkObj.sendBytes(testdata, count: UInt32(testdata.count))
        
    }
    
    /*
    @IBAction func closeButtonClicked(sender: AnyObject ) {
        animationsWindow.close()
    }
*/
}
