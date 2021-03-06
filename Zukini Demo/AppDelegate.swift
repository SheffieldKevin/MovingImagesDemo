//  AppDelegate.swift
//  Zukini Demo
//
//  Copyright (c) 2015 Zukini Ltd.

import Cocoa
import MovingImages

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var windowContoller : ZukiniDemoController!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        MIInitializeCocoaLumberjack()
        windowContoller = ZukiniDemoController(
            windowNibName: "ZukiniDemo")
        windowContoller.showWindow(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

