//  SimpleRendererView.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney. 30/03/2015

import Cocoa
import MovingImages

class SimpleRendererView: NSView {

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

    func assignImage(image: CGImage, identifier: String) -> Void {
        simpleRenderer.assignImage(image, withIdentifier: identifier)
    }

private
    let simpleRenderer = MISimpleRenderer()

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
