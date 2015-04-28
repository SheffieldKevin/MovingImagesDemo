//
//  AppDelegate.swift
//  Spinner2
//
//  Created by Kevin Meaney on 27/04/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var spinnerWindowContoller : SpinnerWindowController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        spinnerWindowContoller = SpinnerWindowController(windowNibName: "SpinnerWindowController")
        spinnerWindowContoller.showWindow(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

