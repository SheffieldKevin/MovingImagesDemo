//  SimpleRendererView.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 30/03/2015.
//  Copyright (c) 2015 Kevin Meaney.

import Cocoa
import MovingImages

class SimpleRendererView: NSView {

    var drawDictionary:[String:AnyObject]?
    
    var variables:[String:AnyObject]? {
        get {
            let theDict = self.simpleRenderer.variables
            if let theDict = theDict {
                return theDict as? [String:AnyObject]
            }
            return Optional.None
        }
        
        set(newVariables) {
            self.simpleRenderer.variables = newVariables
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let theContext = NSGraphicsContext.currentContext()!.CGContext
        CGContextSetTextMatrix(theContext, CGAffineTransformIdentity)
        drawOutlineAndInsetDrawing(theContext)
        if let drawDict = self.drawDictionary {
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }

private
    let simpleRenderer = MISimpleRenderer()

    // Only call from within drawRect.
    func drawOutlineAndInsetDrawing(context: CGContextRef) -> Void {
        let insetRect = CGRectInset(self.bounds, 1.0, 1.0)
        NSColor.grayColor().setStroke()
        CGContextSetLineWidth(context, 2.0)
        CGContextStrokeRect(context, insetRect)
        let innerInsetRect = CGRectInset(insetRect, 2.0, 2.0)
        NSColor.lightGrayColor().setStroke()
        CGContextStrokeRect(context, innerInsetRect)
        let clipRect = CGRectInset(self.bounds, 4.0, 4.0)
        CGContextClipToRect(context, clipRect)
        CGContextTranslateCTM(context, 4, 4)
    }
}
