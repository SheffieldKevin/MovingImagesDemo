//  MIControl.swift
//  MovingImages Demo
//
//  Copyright (c) 2015 Kevin Meaney, MIT License.

import Cocoa
import MovingImages

func createDictionaryFromJSONFile(name: String) -> [String:AnyObject]? {
    let bundle = NSBundle.mainBundle()
    if let url = bundle.URLForResource(name, withExtension: "json"),
       let inStream = NSInputStream(URL: url) {
        inStream.open()
        if let container:AnyObject? = NSJSONSerialization.JSONObjectWithStream(
                inStream, options:NSJSONReadingOptions.allZeros, error:nil),
           let theContainer = container as? [String : AnyObject]
        {
            return theContainer
        }
        else
        {
            return Optional.None
        }
    }
    return Optional.None
}

protocol MISpinnerDelegate: class {
    func spinnerValueChanged(#sender: MISpinner) -> Void
}

class MISpinner: NSControl {

internal
    var minValue:Float = 0.0
    var maxValue:Float = 1.0

    var spinnerValue:Float = 0.5 {
        didSet {
            if let delegate = spinnerDelegate {
                delegate.spinnerValueChanged(sender: self)
            }
        }
    }

    weak var spinnerDelegate:MISpinnerDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.drawDictionary = createDictionaryFromJSONFile("drawarc")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let frame = NSRect(x: 0.0, y: 0.0, width: 140.0, height: 140.0)
        self.drawDictionary = createDictionaryFromJSONFile("drawarc")
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if let drawDict = self.drawDictionary {
            let theContext = NSGraphicsContext.currentContext()!.CGContext
            let controlText = NSString(format: "%1.3f", self.spinnerValue)
            let variables = [
                "controlValue" : self.normalizedControlValue(),
                "controltext" : controlText
            ]
            self.simpleRenderer.variables = variables
            CGContextSetTextMatrix(theContext, CGAffineTransformIdentity)
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }

    override func scrollWheel(theEvent: NSEvent) {
        let deltaY = Float(theEvent.scrollingDeltaY)
        
        self.spinnerValue -= (maxValue - minValue) * deltaY / 1000.0
        if self.spinnerValue < minValue
        {
            self.spinnerValue = minValue
        }
        else if self.spinnerValue > maxValue
        {
            self.spinnerValue = maxValue
        }
        self.setNeedsDisplay()
    }

private
    let simpleRenderer = MISimpleRenderer()
    var drawDictionary:[String:AnyObject]?

    func resetControlValue() -> Void {
        spinnerValue = 0.0
        minValue = 0.0
        maxValue = 1.0
    }
    
    func normalizedControlValue() -> Float {
        if minValue > maxValue ||
           spinnerValue < minValue ||
           spinnerValue > maxValue {
            self.resetControlValue()
        }
        let spread = maxValue - minValue
        return (spinnerValue - minValue) / spread
    }
}
