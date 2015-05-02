//
//  SpinnerPopoverViewController.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 26/04/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

class SpinnerPopoverController: NSViewController {

    @IBOutlet weak var controlKey: NSTextField!
    @IBOutlet weak var maxValue: NSTextField!
    @IBOutlet weak var minValue: NSTextField!
    
    weak var spinnerController: SpinnerController?
    
    @IBAction func handleDone(#sender: NSButton) {
        spinnerController!.dismissPopover()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
