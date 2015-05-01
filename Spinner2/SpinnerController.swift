//  SpinnerController.swift
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

@objc protocol SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) -> Void
}

@IBDesignable
class Spinner: NSControl {
    static let scaleFactor:Float = 100.0
    static let invertedScale:Float = 1.0 / Spinner.scaleFactor

    @IBInspectable var spinnerValue:Float = scaleFactor * 0.5 {
        didSet {
            spinnerValue = max(min(spinnerValue, Spinner.scaleFactor), 0.0)
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
    
    override var acceptsFirstResponder: Bool { return true }
    
    weak var controller: SpinnerController?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.drawDictionary = createDictionaryFromJSONFile("drawarc",
            inBundle: NSBundle(forClass: self.dynamicType))
        // bundle = NSBundle(forClass: Class.self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawDictionary = createDictionaryFromJSONFile("drawarc",
            inBundle: NSBundle(forClass: self.dynamicType))
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
                "controlvalue" : spinnerValue * Spinner.invertedScale,
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
        let newValue = self.spinnerValue - deltaY * 0.06
        self.spinnerValue = newValue
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if let controller = self.controller {
            if (theEvent.modifierFlags.rawValue & NSEventModifierFlags.AlternateKeyMask.rawValue) != 0 {
                controller.displayPopover(self)
            }
        }
    }

    override func prepareForInterfaceBuilder() {
        if let controller = self.controller {
            controller.maxValue = Spinner.scaleFactor
        }
    }

private
    let simpleRenderer = MISimpleRenderer()
    var drawDictionary:[String:AnyObject]?
    
}

class SpinnerController: NSViewController, NSPopoverDelegate {

    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        self.popoverViewController = SpinnerPopoverViewController(
            nibName: "SpinnerPopover", bundle: nil)
        self.popoverViewController?.spinnerController = self
        popover.contentViewController = self.popoverViewController!
        popover.delegate = self
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        return popover
    }()
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    weak var delegate: SpinnerDelegate?
    var popoverViewController: SpinnerPopoverViewController?
    
    func displayPopover(sender: Spinner) -> Void {
        let thePopover = self.popover
        popover.showRelativeToRect(self.view.bounds, ofView: self.view,
            preferredEdge: NSMaxYEdge)
        popoverViewController?.maxValue?.floatValue = self.maxValue
        popoverViewController?.minValue?.floatValue = self.minValue
        popoverViewController?.controlKey?.stringValue = self.variableKey
    }

    func dismissPopover() {
        if let popoverViewController = popoverViewController {
            self.minValue = popoverViewController.minValue!.floatValue
            self.maxValue = popoverViewController.maxValue!.floatValue
            self.variableKey = popoverViewController.controlKey!.stringValue
            self.popover.performClose(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let spinner = self.view as? Spinner {
            spinner.controller = self
            self.minValue = -1.0
            self.maxValue = 1.0
            self.variableKey = "test"
        }
    }

    var spinnerValue:Float {
        get {
            if let spinner = self.view as? Spinner {
                return spinner.spinnerValue * (maxValue - minValue) * Spinner.invertedScale + minValue
            }
            return 0.5
        }
        
        set(newValue) {
            if let spinner = self.view as? Spinner {
                spinner.spinnerValue = (newValue - minValue) * Spinner.scaleFactor / (maxValue - minValue)
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

