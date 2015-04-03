//
//  AppDelegate.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 30/03/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var simpleRendererWindowContoller : SimpleRendererWindowController!
    
    @IBAction func displaySimpleRenderer(sender: AnyObject) -> Void {
        simpleRendererWindowContoller = SimpleRendererWindowController(
                                            windowNibName: "SimpleRenderer")
        simpleRendererWindowContoller.showWindow(sender)
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

