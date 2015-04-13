//  SimpleRenderer.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney. 30/03/2015.

import Cocoa
import MovingImages


class SimpleRendererWindowController:NSWindowController, NSTextViewDelegate,
                                     MISpinnerDelegate {

    static var InitialKeyOne = "variable1"
    static var InitialKeyTwo = "variable2"

    @IBAction func controlkey1Changed(sender: AnyObject) {
        variableKeyOne = sender.stringValue
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
        variableKeyTwo = sender.stringValue
    }
    
    @IBAction func control2MinChanged(sender: AnyObject) {
        spinnerTwo.minValue = sender.floatValue
        minValueTwo = sender.floatValue
    }

    @IBAction func control2MaxChanged(sender: AnyObject) {
        spinnerTwo.maxValue = sender.floatValue
        maxValueTwo = sender.floatValue
    }

    var variableKeyOne:String = InitialKeyOne
    var variableKeyTwo:String = InitialKeyTwo

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

    @IBOutlet weak var spinnerOne: MISpinner!
    @IBOutlet weak var spinnerTwo: MISpinner!
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
                            self.variableKeyOne = varKey
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
                    spinnerOne.needsDisplay = true
                }
                if variableDefs.count > 1 {
                    let variableDef:AnyObject = variableDefs[1]
                    if let variableDef = variableDef as? [String:AnyObject] {
                        if let variableKey:AnyObject = variableDef["variablekey"],
                           let varKey = variableKey as? String {
                            self.variableKeyTwo = varKey
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
                    spinnerTwo.needsDisplay = true
                }
            }
            simpleRenderView.needsDisplay = true
        }
        simpleRenderView.variables = self.variables
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        drawElementJSON.delegate = self
        spinnerOne.spinnerDelegate = self
        spinnerTwo.spinnerDelegate = self
        drawElementJSON.automaticQuoteSubstitutionEnabled = false
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
    
    func spinnerValueChanged(#sender: MISpinner) {
        simpleRenderView.variables = self.variables
        simpleRenderView.needsDisplay = true
    }
    
private
    var variables:[String:AnyObject] {
        get {
            return [
                variableKeyOne : spinnerOne.spinnerValue,
                variableKeyTwo : spinnerTwo.spinnerValue,
                MIJSONKeyWidth : simpleRenderView.frame.width - 8,
                MIJSONKeyHeight : simpleRenderView.frame.height - 8
            ]
        }
    }
}
