//  ZukiniRendererView.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

class ZukiniRendererView: NSView {
    
    var drawDictionary:[String:AnyObject]?
    var drawWidth:CGFloat {
        get {
            let theWidth = self.frame.width - 8.0
            if theWidth < 0.0 {
                return 0
            }
            else {
                return theWidth
            }
        }
    }
    
    var drawHeight:CGFloat {
        get {
            let theHeight = self.frame.height - 8.0
            if theHeight < 0.0 {
                return 0
            }
            else {
                return theHeight
            }
        }
    }
    
    var variables:[String:AnyObject]? {
        get {
            if let theRenderer = self.simpleRenderer,
                let theDict = theRenderer.variables {
                return theDict as? [String:AnyObject]
            }
            return Optional.None
        }
        
        set(newVariables) {
            self.simpleRenderer?.variables = newVariables
        }
    }
    
    func makeNewRenderer(#miContext:MIContext) {
        simpleRenderer = MISimpleRenderer(MIContext: miContext)
    }

    override func drawRect(dirtyRect: NSRect) {
        let theContext = NSGraphicsContext.currentContext()!.CGContext
        CGContextSetTextMatrix(theContext, CGAffineTransformIdentity)
        drawOutlineAndInsetDrawing(theContext)
        if let drawDict = self.drawDictionary,
            let theRenderer = self.simpleRenderer
        {
            theRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }

    /*
    func assignImage(image: CGImage, identifier: String) -> Void {
        simpleRenderer?.assignImage(image, withIdentifier: identifier)
    }
    */

    private
    var simpleRenderer:MISimpleRenderer?
    
    // Only call from within drawRect.
    func drawOutlineAndInsetDrawing(context: CGContextRef) -> Void {
        let insetRect = CGRectInset(self.bounds, 1.0, 1.0)
        NSColor.lightGrayColor().setStroke()
        CGContextSetLineWidth(context, 2.0)
        CGContextStrokeRect(context, insetRect)
        let innerInsetRect = CGRectInset(insetRect, 1.0, 1.0)
        NSColor(deviceWhite: 0.9, alpha: 1.0).setFill()
        CGContextFillRect(context, innerInsetRect)
        let clipRect = CGRectInset(self.bounds, 4.0, 4.0)
        CGContextClipToRect(context, clipRect)
        CGContextTranslateCTM(context, 4.0, 4.0)
    }
}

