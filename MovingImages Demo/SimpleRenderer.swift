//  SimpleRenderer.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney. 30/03/2015.

import Cocoa
import MovingImages


class SimpleRendererWindowController:NSWindowController, NSTextViewDelegate,
                                     SpinnerDelegate {

    static var InitialKeyOne = "variable1"
    static var InitialKeyTwo = "variable2"

    @IBAction func controlkey1Changed(sender: AnyObject) {
        spinnerOne.variableKey = sender.stringValue
    }
    
    @IBAction func control1MinChanged(sender: AnyObject) {
        spinnerOne.minValue = sender.floatValue
        minValueOne = sender.floatValue
    }
    
    @IBAction func control1MaxChanged(sender: AnyObject) {
        spinnerOne.maxValue = sender.floatValue
        maxValueOne = sender.floatValue
    }

    @IBAction func controlkey2Changed(sender: AnyObject) {
        spinnerTwo.variableKey = sender.stringValue
    }
    
    @IBAction func control2MinChanged(sender: AnyObject) {
        spinnerTwo.minValue = sender.floatValue
        minValueTwo = sender.floatValue
    }

    @IBAction func control2MaxChanged(sender: AnyObject) {
        spinnerTwo.maxValue = sender.floatValue
        maxValueTwo = sender.floatValue
    }

    var minValueOne:Float {
        get {
            return spinnerOne.minValue
        }
        set(newValue) {
            spinnerOne.minValue = newValue
        }
    }

    var maxValueOne:Float {
        get {
            return spinnerOne.maxValue
        }
        set(newValue) {
            spinnerOne.maxValue = newValue
        }
    }

    var minValueTwo:Float {
        get {
            return spinnerTwo.minValue
        }
        set(newValue) {
            spinnerTwo.minValue = newValue
        }
    }

    var maxValueTwo:Float {
        get {
            return spinnerTwo.maxValue
        }
        set(newValue) {
            spinnerTwo.maxValue = newValue
        }
    }

    @IBOutlet var drawElementJSON: NSTextView!
    
    @IBOutlet weak var simpleRenderView: SimpleRendererView!

    @IBOutlet weak var spinnerOne: SpinnerController!
    @IBOutlet weak var spinnerTwo: SpinnerController!
    @IBOutlet weak var spinnerThree: SpinnerController!
    @IBOutlet weak var spinnerFour: SpinnerController!
    @IBOutlet weak var exampleList: NSPopUpButton!
    @IBOutlet weak var control1Key: NSTextField!
    @IBOutlet weak var control1Minimum: NSTextField!
    @IBOutlet weak var control1Maximum: NSTextField!
    
    @IBOutlet weak var control2Key: NSTextField!
    @IBOutlet weak var control2Minimum: NSTextField!
    @IBOutlet weak var control2Maximum: NSTextField!

    @IBAction func exampleSelected(sender: AnyObject) {
        let popup = sender as! NSPopUpButton
        let selectedTitle = popup.titleOfSelectedItem!
        let filePath = exampleNameToFilePath(selectedTitle,
            prefix: "simple_renderer_")
        if let dictionary = readJSONFromFile(filePath),
           let instructions:AnyObject = dictionary[MIJSONPropertyDrawInstructions],
           let drawInstructions = instructions as? [String:AnyObject],
           let jsonString = makePrettyJSONFromDictionary(drawInstructions)
        {
            drawElementJSON.string = jsonString
            if let theDict = createDictionaryFromJSONString(jsonString) {
                simpleRenderView.drawDictionary = theDict
            }
            if let variableDefinitions:AnyObject = dictionary["variabledefinitions"],
               let variableDefs = variableDefinitions as? [AnyObject]
            {
                if variableDefs.count > 0 {
                    let variableDef:AnyObject = variableDefs[0]
                    if let variableDef = variableDef as? [String:AnyObject] {
                        if let variableKey:AnyObject = variableDef["variablekey"],
                           let varKey = variableKey as? String {
                            // self.variableKeyOne = varKey
                            self.spinnerOne.variableKey = varKey
                            self.control1Key.stringValue = varKey
                        }
                        
                        if let minimumValue:AnyObject = variableDef["minvalue"],
                           let minValue = minimumValue as? Float {
                            self.minValueOne = minValue
                            self.control1Minimum.floatValue = minValue
                        }
                        
                        if let maximumValue:AnyObject = variableDef["maxvalue"],
                           let maxValue = maximumValue as? Float {
                            self.maxValueOne = maxValue
                            self.control1Maximum.floatValue = maxValue
                        }

                        if let defaultValue:AnyObject = variableDef["defaultvalue"],
                           let defValue = defaultValue as? Float {
                            self.spinnerOne.spinnerValue = defValue
                        }
                    }
                    // spinnerOne.needsDisplay = true
                }
                if variableDefs.count > 1 {
                    let variableDef:AnyObject = variableDefs[1]
                    if let variableDef = variableDef as? [String:AnyObject] {
                        if let variableKey:AnyObject = variableDef["variablekey"],
                           let varKey = variableKey as? String {
                            // self.variableKeyTwo = varKey
                            self.spinnerTwo.variableKey = varKey
                            self.control2Key.stringValue = varKey
                        }
                        
                        if let minimumValue:AnyObject = variableDef["minvalue"],
                           let minValue = minimumValue as? Float {
                             self.minValueTwo = minValue
                             self.control2Minimum.floatValue = minValue
                        }
                        
                        if let maximumValue:AnyObject = variableDef["maxvalue"],
                           let maxValue = maximumValue as? Float {
                              self.maxValueTwo = maxValue
                              self.control2Maximum.floatValue = maxValue
                        }
                        if let defaultValue:AnyObject = variableDef["defaultvalue"],
                           let defValue = defaultValue as? Float {
                            self.spinnerTwo.spinnerValue = defValue
                        }
                    }
                    // spinnerTwo.needsDisplay = true
                }
            }
            simpleRenderView.needsDisplay = true
        }
        simpleRenderView.variables = self.variables
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if let theWindow = self.window {
            theWindow.backgroundColor = NSColor(deviceWhite: 0.15, alpha: 1.0)
        }
        drawElementJSON.delegate = self
        spinnerOne.delegate = self
        spinnerTwo.delegate = self
        drawElementJSON.automaticQuoteSubstitutionEnabled = false
        drawElementJSON.font = NSFont(name: "Menlo-Regular", size: 11)
        drawElementJSON.textColor = NSColor(deviceWhite: 0.95, alpha: 1.0)
        drawElementJSON.backgroundColor = NSColor(deviceWhite: 0.25, alpha: 1.0)
        drawElementJSON.selectedTextAttributes = [
            NSBackgroundColorAttributeName : NSColor.lightGrayColor(),
            NSForegroundColorAttributeName : NSColor.blackColor()
        ]
        simpleRenderView.variables = self.variables
        if let theImage = createCGImage("Sculpture", fileExtension: "jpg") {
            simpleRenderView.assignImage(theImage, identifier: "Sculpture")
        }
        
        exampleList.addItemsWithTitles(listOfExamples(prefix: "simple_renderer_"))
        self.exampleSelected(exampleList)
    }
    
    func textDidChange(notification: NSNotification) {
        if let jsonText = drawElementJSON.string,
            let theDict = createDictionaryFromJSONString(jsonText) {
            simpleRenderView.drawDictionary = theDict
            simpleRenderView.variables = self.variables
            simpleRenderView.needsDisplay = true
        }
    }
    
    func spinnerValueChanged(#sender: SpinnerController) {
        simpleRenderView.variables = self.variables
        simpleRenderView.needsDisplay = true
    }
    
private
    var variables:[String:AnyObject] {
        get {
            var theDictionary:[String:AnyObject] = [:]
            theDictionary[spinnerTwo.variableKey] = spinnerTwo.spinnerValue
            theDictionary[spinnerOne.variableKey] = spinnerOne.spinnerValue
            theDictionary[MIJSONKeyWidth] = simpleRenderView.frame.width - 8
            theDictionary[MIJSONKeyHeight] = simpleRenderView.frame.height - 8
            return theDictionary
        }
    }
}
