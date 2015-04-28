//  SpinnerController.swift
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

@objc protocol SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) -> Void
}

class Spinner: NSControl {
    var spinnerValue:Float = 0.5 {
        didSet {
            if let controller = self.controller {
                controller.spinnerValueChanged(spinner: self)
            }
            self.needsDisplay = true
        }
    }

    var label:String = "" {
        didSet {
            self.needsDisplay = true
        }
    }
    
    @IBOutlet weak var controller: SpinnerController?

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
            let text:String
            if let controller = self.controller {
                let value = controller.spinnerValue
                text = value.stringWithMaxnumberOfFractionAndIntDigits(4)
            }
            else {
                text = spinnerValue.stringWithMaxnumberOfFractionAndIntDigits(4)
            }
            let variables:[String:AnyObject] = [
                "controlvalue" : spinnerValue,
                "controltext" : text,
                "controllabel" : label
            ]
            self.simpleRenderer.variables = variables
            CGContextSetTextMatrix(theContext, CGAffineTransformIdentity)
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        let deltaY = Float(theEvent.scrollingDeltaY)
        let newValue = self.spinnerValue - deltaY * 0.0001
        self.spinnerValue = max(min(newValue, 1.0), 0.0)
    }
    
    private
    let simpleRenderer = MISimpleRenderer()
    var drawDictionary:[String:AnyObject]?
    
}

class SpinnerController: NSViewController, NSPopoverDelegate {

    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        popover.contentViewController = SpinnerPopoverViewController()
        popover.delegate = self
        return popover
    }()
    
    weak var delegate: SpinnerDelegate?
    
    @IBAction func displayPopover(sender: Spinner) -> Void {
        popover.showRelativeToRect(self.view.frame, ofView: self.view, preferredEdge: NSMaxYEdge)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    var spinnerValue:Float {
        get {
            if let spinner = self.view as? Spinner {
                return spinner.spinnerValue * (maxValue - minValue)
            }
            return 0.5
        }
        
        set(newValue) {
            if let spinner = self.view as? Spinner {
                spinner.spinnerValue = newValue / (maxValue - minValue)
            }
        }
    }

    var minValue:Float = 0.0 {
        didSet {
            if minValue > maxValue {
                maxValue = minValue + 1.0
            }
            
            if spinnerValue < minValue {
                spinnerValue = minValue
            }
            self.view.needsDisplay = true
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
            self.view.needsDisplay = true
        }
    }
    
    var variableKey:String {
        get {
            if let spinner = self.view as? Spinner {
                return spinner.label
            }
            return ""
        }
        set(newValue) {
            if let spinner = self.view as? Spinner {
                spinner.label = newValue
            }
        }
    }
    
    func spinnerValueChanged(#spinner: Spinner) -> Void {
        if let delegate = self.delegate {
            delegate.spinnerValueChanged(sender: self)
        }
    }
}

