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

class MISpinner: NSControl {

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
                "controlValue" : self.spinnerValue,
                "controltext" : controlText
            ]
            self.simpleRenderer.variables = variables
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }

    override func scrollWheel(theEvent: NSEvent) {
        let deltaY = Float(theEvent.scrollingDeltaY)
        
        self.spinnerValue -= deltaY / 1000.0
        if self.spinnerValue < minimumValue
        {
            self.spinnerValue = minimumValue
        }
        else if self.spinnerValue > maximimValue
        {
            self.spinnerValue = maximimValue
        }
        self.setNeedsDisplay()
    }

private
    let simpleRenderer = MISimpleRenderer()

    var spinnerValue = Float(0.5)
    
    let minimumValue:Float = 0.0
    let maximimValue:Float = 1.0

    var drawDictionary:[String:AnyObject]?
}
