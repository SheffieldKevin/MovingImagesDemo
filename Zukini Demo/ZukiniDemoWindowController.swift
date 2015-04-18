//
//  ZukiniDemoWindowController.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 16/04/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

class ZukiniDemoWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        if let theWindow = self.window {
            theWindow.backgroundColor = NSColor(deviceWhite: 0.15, alpha: 1.0)
        }
    }
}
