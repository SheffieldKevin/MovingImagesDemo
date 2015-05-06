//  SpinnerController.swift
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

// MARK: SpinnerDelegate protocol declaration
@objc protocol SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) -> Void
}

// MARK: Spinner Class
@IBDesignable
class Spinner: NSControl {
    // MARK: Spinner Class properties
    private static let scaleFactor:Float = 100.0
    private static let invertedScale:Float = 1.0 / Spinner.scaleFactor

    @IBInspectable var spinnerValue:Float = scaleFactor * 0.5 {
        didSet {
            spinnerValue = max(min(spinnerValue, Spinner.scaleFactor), 0.0)
            if let controller = self.controller {
                controller.spinnerValueChanged(spinner: self)
            }
            self.needsDisplay = true
        }
    }

    private weak var controller: SpinnerController?

    // MARK: Required init
    required init?(coder: NSCoder) {
        let theDictionary = createDictionaryFromJSONFile("drawarc",
            inBundle: NSBundle(forClass: self.dynamicType))
        drawDictionary = theDictionary?[MIJSONPropertyDrawInstructions] as? [String:AnyObject]
        equation = theDictionary?["valuefrompositionequation"] as? String
        super.init(coder: coder)
    }

    // MARK: NSView method and property overrides.
    override init(frame frameRect: NSRect) {
        let theDictionary = createDictionaryFromJSONFile("drawarc",
            inBundle: NSBundle(forClass: self.dynamicType))
        drawDictionary = theDictionary?[MIJSONPropertyDrawInstructions] as? [String:AnyObject]
        equation = theDictionary?["valuefrompositionequation"] as? String
        super.init(frame: frameRect)
        // bundle = NSBundle(forClass: Spinner.self)
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func awakeFromNib() {
        let trackingArea = NSTrackingArea(rect: visibleRect,
            options: NSTrackingAreaOptions.MouseEnteredAndExited |
                    NSTrackingAreaOptions.MouseMoved |
                    NSTrackingAreaOptions.InVisibleRect |
                    NSTrackingAreaOptions.ActiveAlways,
            owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if let drawDict = self.drawDictionary {
            let theContext = NSGraphicsContext.currentContext()!.CGContext
            simpleRenderer.variables = createVariablesDictionaryForDrawing()
            CGContextSetTextMatrix(theContext, CGAffineTransformIdentity)
            simpleRenderer.drawDictionary(drawDict, intoCGContext: theContext)
        }
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        let deltaY = Float(theEvent.scrollingDeltaY)
        let newValue = self.spinnerValue - deltaY * 0.06
        self.spinnerValue = newValue
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        if (theEvent.modifierFlags.rawValue & NSEventModifierFlags.CommandKeyMask.rawValue) != 0 {
            let clickLocation: CGPoint = self.convertPoint(
                theEvent.locationInWindow, fromView: nil)
            setValueFromLocation(clickLocation)
        }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if (theEvent.modifierFlags.rawValue &
            NSEventModifierFlags.AlternateKeyMask.rawValue) != 0 {
            controller?.displayPopover(self)
        }
        else {
            let clickLocation: CGPoint = self.convertPoint(
                theEvent.locationInWindow, fromView: nil)
            setValueFromLocation(clickLocation)
        }
    }

    override func prepareForInterfaceBuilder() {
        if let controller = self.controller {
            controller.maxValue = Spinner.scaleFactor
        }
    }

    // MARK: Private and Final instance methods.
    private final func setValueFromLocation(location: CGPoint) -> Void {
        if let equation = self.equation {
            let valueDict = createVariablesDictionaryForValue(location)
            var newValue: CGFloat = 0.0
            if (MIUtilityGetFloatFromString(equation, &newValue, valueDict))
            {
                self.spinnerValue = Float(newValue) * Spinner.scaleFactor
            }
        }
    }
    
    private final func createVariablesDictionaryForDrawing() -> [String:AnyObject] {
        let text:String
        if let controller = self.controller {
            let value = controller.spinnerValue
            text = value.stringWithMaxnumberOfFractionAndIntDigits(4)
        }
        else {
            text = spinnerValue.stringWithMaxnumberOfFractionAndIntDigits(4)
        }

        return [
            "controlvalue" : spinnerValue * Spinner.invertedScale,
            "controllabel" : self.label,
            MIJSONKeyWidth : self.bounds.width,
            MIJSONKeyHeight : self.bounds.height,
            "controlcenterx" : self.bounds.width * 0.5,
            "controlcentery" : self.bounds.height * 0.5,
            "controltext" : text
        ]
    }

    private final func createVariablesDictionaryForValue(mouseDown: CGPoint) ->
        [String:AnyObject] {
        return [
            MIJSONKeyWidth : self.bounds.width,
            MIJSONKeyHeight : self.bounds.height,
            MIJSONKeyX : mouseDown.x,
            MIJSONKeyY : mouseDown.y,
            "controlcenterx" : self.bounds.width * 0.5,
            "controlcentery" : self.bounds.height * 0.5
        ]
    }

    // MARK: Private instance properties
    private var label:String = "" {
        didSet {
            self.needsDisplay = true
        }
    }
    private let simpleRenderer = MISimpleRenderer()
    private let drawDictionary:[String:AnyObject]?
    private let equation:String?
}

// MARK: SpinnerController Class
class SpinnerController: NSViewController, NSPopoverDelegate {

    // MARK: SpinnerController required init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: SpinnerController NSControl/NSView method overrides
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let spinner = self.view as? Spinner {
            spinner.controller = self
            self.minValue = -1.0
            self.maxValue = 1.0
            self.variableKey = "test"
            self.view.window?.acceptsMouseMovedEvents = true
        }
    }
    
    // MARK: Public instance properties
    weak var delegate: SpinnerDelegate?
    var popoverController: SpinnerPopoverController?
    
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .Semitransient
        self.popoverController = SpinnerPopoverController(
            nibName: "SpinnerPopover", bundle: nil)
        self.popoverController?.spinnerController = self
        popover.contentViewController = self.popoverController!
        popover.delegate = self
        popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        return popover
    }()
    
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

    // MARK: Public instance methods.
    func displayPopover(sender: Spinner) -> Void {
        let thePopover = self.popover
        popover.showRelativeToRect(self.view.bounds, ofView: self.view,
            preferredEdge: NSMaxYEdge)
        popoverController?.maxValue?.floatValue = self.maxValue
        popoverController?.minValue?.floatValue = self.minValue
        popoverController?.controlKey?.stringValue = self.variableKey
    }
    
    func dismissPopover() {
        if let popoverViewController = popoverController {
            self.minValue = popoverViewController.minValue!.floatValue
            self.maxValue = popoverViewController.maxValue!.floatValue
            self.variableKey = popoverViewController.controlKey!.stringValue
            self.popover.performClose(self)
        }
    }
    
    func spinnerValueChanged(#spinner: Spinner) -> Void {
        if let delegate = self.delegate {
            delegate.spinnerValueChanged(sender: self)
        }
    }
    
    func configureSpinner(#dictionary: [String:AnyObject]) -> Void {
        if let theKey = dictionary["variablekey"] as? String {
            self.variableKey = theKey
        }
        
        if let maxValue = dictionary["maxvalue"] as? Float {
            self.maxValue = maxValue
        }

        if let minValue = dictionary["minvalue"] as? Float {
            self.minValue = minValue
        }

        if let defaultValue = dictionary["defaultvalue"] as? Float {
            self.spinnerValue = defaultValue
        }
    }
    
    func spinnerDictionary() -> [String:AnyObject] {
        var theDict = [String:AnyObject]()
        theDict["variablekey"] = self.variableKey
        theDict["maxvalue"] = self.maxValue
        theDict["minvalue"] = self.minValue
        theDict["defaultvalue"] = self.spinnerValue
        return theDict
    }
}

