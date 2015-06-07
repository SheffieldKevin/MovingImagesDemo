//  SpinnerPopoverViewController.swift
//  MovingImages Demo
//
//  Copyright (c) 2015 Zukini Ltd.

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
