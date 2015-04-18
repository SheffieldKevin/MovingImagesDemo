//
//  AppDelegate.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 30/03/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa
import MovingImages

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var simpleRendererWindowContoller : SimpleRendererWindowController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        MIInitializeCocoaLumberjack()
        simpleRendererWindowContoller = SimpleRendererWindowController(
            windowNibName: "SimpleRenderer")
        simpleRendererWindowContoller.showWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

