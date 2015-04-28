//
//  SpinnerPopoverViewController.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 26/04/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

class SpinnerPopoverViewController: NSViewController {

    @IBOutlet weak var controlKey: NSTextField!
    @IBOutlet weak var maxValue: NSTextField!
    @IBOutlet weak var minValue: NSTextField!
    
    weak var spinnerController: SpinnerController?
    
    @IBAction func handleDone(#sender: NSButton) {
        spinnerController!.dismissPopover()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        super.view.window?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        // Do view setup here.
    }
}
