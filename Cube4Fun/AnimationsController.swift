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

var _animationArray: [NSMutableDictionary] = [NSMutableDictionary]();


class AnimationsController: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var myTableView: NSTableView!
    
    var _selectedRow: Int = -1
    
    override func awakeFromNib() {
        _animationArray.append(_emptyAnimation)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let numberOfRows:Int = _animationArray.count
        return numberOfRows
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        //println("Display: \(row)")
        let object: NSDictionary = _animationArray[row] as NSDictionary
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
        let view: NSTableView = notification.object as NSTableView
        _selectedRow = view.selectedRow
        
        //println("klicked \(view.selectedRow)")
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        let column: String = tableColumn?.identifier as String!
        //println("Object: \(object) Key: \((tableColumn?.identifier)!)" )

        let value = object! as NSString
        if  column == "AnimName" {
            _animationArray[row].setObject(value, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimKey" {
            _animationArray[row].setObject(value, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimDur" {
            _animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimSpeed" {
            _animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        }
        if column == "AnimFrames" {
            _animationArray[row].setObject(value.integerValue, forKey: (tableColumn?.identifier)!)
        }
    }
    
    @IBAction func addNewAnimation(sender: AnyObject) {
        _animationArray.append(_emptyAnimation)
        myTableView.reloadData()
  //      println("Adding new Item")
    }
    
    @IBAction func delNewAnimation(sender: AnyObject) {
        if ( _selectedRow >= 0 ) {
            _animationArray.removeAtIndex(_selectedRow)
            myTableView.reloadData()
        }
//        println("Deleting selected Item")
    }
    
    @IBAction func moveUpItem(send: AnyObject) {
        if ( _selectedRow > 0 ) {
            _animationArray.insert(_animationArray[_selectedRow], atIndex: _selectedRow-1)
            _animationArray.removeAtIndex(_selectedRow+1)
            myTableView.reloadData()
            myTableView.selectRowIndexes(NSIndexSet(index: _selectedRow-1), byExtendingSelection: false)
//            let save: NSMutableDictionary =  dataArray.
        }
    }
    
    @IBAction func moveDownItem(send: AnyObject) {
        if (_selectedRow < _animationArray.count - 1) {
            _animationArray.insert(_animationArray[_selectedRow+1], atIndex: _selectedRow)
            _animationArray.removeAtIndex(_selectedRow+2)
            myTableView.reloadData()
            myTableView.selectRowIndexes(NSIndexSet(index: _selectedRow+1), byExtendingSelection: false)
        }
    }
    
    /*
    @IBAction func closeButtonClicked(sender: AnyObject ) {
        animationsWindow.close()
    }
*/
}
