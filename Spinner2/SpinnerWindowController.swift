//
//  SpinnerWindowController.swift
//  Spinner2
//
//  Created by Kevin Meaney on 27/04/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

class SpinnerWindowController: NSWindowController {
    var spinner2Controller: SpinnerController!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let theWindow = self.window!
        theWindow.backgroundColor = NSColor(deviceWhite: 0.15, alpha: 1.0)
        
        spinner2Controller = SpinnerController(nibName: "SpinnerController", bundle: nil)
        theWindow.contentView.addSubview(spinner2Controller.view)
        spinner2Controller.view.frame = NSRect(x: 180.0, y: 110.0, width: 140, height: 140)
/*
        let control = spinner2Controller.view as! Spinner
        println("Enabled: \(control.enabled)")
        println("Accepts first responder: \(control.acceptsFirstResponder)")
        println("Refuses first responder: \(control.refusesFirstResponder())")
*/
    }
}
