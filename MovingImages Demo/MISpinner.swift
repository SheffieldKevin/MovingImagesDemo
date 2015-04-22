//  MIControl.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney, MIT License.

import Cocoa
import MovingImages

protocol MISpinnerDelegate: class {
    func spinnerValueChanged(#sender: MISpinner) -> Void
}

extension Double {
    func stringWithMaxnumberOfFractionAndIntDigits(maxnumber: Int) -> String {
        let numIntDigits:Int
        if self > 0.9999 {
            numIntDigits = Int(log10(self))
        }
        else if self < -0.9999 {
            numIntDigits = Int(log10(-self))
        }
        else {
            numIntDigits = 0
        }
        let numDigits:Int = maxnumber
        let numFractionDigits:Int
        if numIntDigits > numDigits {
            numFractionDigits = 0
        }
        else {
            numFractionDigits = numDigits - numIntDigits - 1
        }
        let format = String(format: "%%.%if", numFractionDigits)
        return String(format: format, self)
    }
}

extension Float {
    func stringWithMaxnumberOfFractionAndIntDigits(maxnumber: Int) -> String {
        return Double(self).stringWithMaxnumberOfFractionAndIntDigits(maxnumber)
    }
}

class MISpinner: NSControl, NSPopoverDelegate {

internal
    var minValue:Float = 0.0 {
        didSet {
            if minValue > maxValue {
                maxValue = minValue + 1.0
            }
            
            if spinnerValue < minValue {
                spinnerValue = minValue
            }
            self.setNeedsDisplay()
        }
    }
    
    var maxValue:Float = 1.0 {
        didSet {
            if maxValue < minValue {
                minValue = maxValue - 1
            }
            
            if spinnerValue > maxValue {
                spinnerValue = maxValue
            }
            self.setNeedsDisplay()
        }
    }

    var spinnerValue:Float = 0.5 {
        didSet {
            if let delegate = spinnerDelegate {
                delegate.spinnerValueChanged(sender: self)
            }
        }
    }
    
    var label:String = "" {
        didSet {
            self.setNeedsDisplay()
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
            let controlText = spinnerValue.stringWithMaxnumberOfFractionAndIntDigits(4)
            let variables:[String:AnyObject] = [
                "controlValue" : self.normalizedControlValue(),
                "controltext" : controlText,
                "controllabel" : label
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

    func normalizedControlValue() -> Float {
        return (spinnerValue - minValue) / (maxValue - minValue)
    }
}
