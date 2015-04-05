//
//  ProjectController.swift
//  Cube4Fun
//
//  Created by Nik on 02.04.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import Cocoa

class AnimationsController: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var animationsWindow: NSWindow!
    @IBOutlet weak var myTableView: NSTableView!
    
    var dataArray: [NSMutableDictionary] = [["AnimName": "Animation1", "AnimKey": "1=anim1", "AnimDur": 3, "AnimSpeed": 700, "AnimFrames": 12],
        ["AnimName": "Animation2", "AnimKey": "1=anim2", "AnimDur": 7, "AnimSpeed": 1700, "AnimFrames": 17],
        ["AnimName": "Animation3", "AnimKey": "1=anim3", "AnimDur": 1, "AnimSpeed": 500, "AnimFrames": 22],
        ["AnimName": "Animation4", "AnimKey": "1=anim4", "AnimDur": 10, "AnimSpeed": 500, "AnimFrames": 32],
        ["AnimName": "Animation5", "AnimKey": "1=anim5", "AnimDur": 23, "AnimSpeed": 500, "AnimFrames": 18],
        ["AnimName": "Animation6", "AnimKey": "1=anim6", "AnimDur": 2, "AnimSpeed": 1000, "AnimFrames": 52]];
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let numberOfRows:Int = dataArray.count
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        println("Display: \(row)")
        let object: NSDictionary = dataArray[row] as NSDictionary
        //println(object)
        let column: String = tableColumn?.identifier as String!
        if  column == "AnimName" {
            let value = object.objectForKey(column) as String
            return value
        }
        if column == "AnimKey" {
            let value = object.objectForKey(column) as String
            return value
        }
        if column == "AnimDur" {
            let value = object.objectForKey(column) as Int
            return value
        }
        if column == "AnimSpeed" {
            let value = object.objectForKey(column) as Int
            return value
        }
        if column == "AnimFrames" {
            let value = object.objectForKey(column) as Int
            return value
        }

        return column
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        println("klicked")
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        dataArray[row].setObject(object!, forKey: (tableColumn?.identifier)!)
    }
    
    /*
    @IBAction func closeButtonClicked(sender: AnyObject ) {
        animationsWindow.close()
    }
*/
}
