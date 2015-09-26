//  AppDelegate.swift
//  MovingImages Demo
//
//  Copyright (c) 2015 Zukini Ltd.

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

    @IBAction func exportAsJSON(sender sender: AnyObject) {
        if let windowController = simpleRendererWindowContoller {
            windowController.exportJSON(sender: sender)
        }
    }
    
    @IBAction func importJSON(sender sender: AnyObject)  {
        if let windowController = simpleRendererWindowContoller {
            windowController.importJSON(sender: sender)
        }
    }
}

