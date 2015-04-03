//
//  SimpleRendererView.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 30/03/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa
import MovingImages

class SimpleRendererView: NSView {

    var drawDictionary:[String:AnyObject]?
    
    override func drawRect(dirtyRect: NSRect) {
        if let drawDict = self.drawDictionary {
            let theContext = NSGraphicsContext.currentContext()!.CGContext
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }

private
    let simpleRenderer = MISimpleRenderer()
}
