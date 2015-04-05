//
//  SimpleRenderer.swift
//  MovingImages Demo
//
//  Created by Kevin Meaney on 30/03/2015.
//  Copyright (c) 2015 Kevin Meaney. All rights reserved.
//

import Cocoa

func createDictionaryFromJSONString(jsonString: String) -> [String:AnyObject]? {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
        let theDict = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.allZeros, error:nil) as? [String:AnyObject] {
        return theDict
    }
    return Optional.None
}

class SimpleRendererWindowController:NSWindowController, NSTextViewDelegate,
                                     MISpinnerDelegate {

    static var InitialKeyOne = "variable1"
    static var InitialKeyTwo = "variable2"

    @IBAction func controlkey1Changed(sender: AnyObject) {
        variableKeyOne = sender.stringValue
    }
    
    @IBAction func controlkey2Changed(sender: AnyObject) {
        variableKeyTwo = sender.stringValue
    }

    var variableKeyOne:String {
        get {
            return variableKey1
        }
        set(newValue) {
            variableKey1 = newValue
        }
    }

    var variableKeyTwo:String {
        get {
            return variableKey2
        }
        set(newValue) {
            variableKey2 = newValue
        }
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

    @IBOutlet weak var spinnerOne: MISpinner!
    @IBOutlet weak var spinnerTwo: MISpinner!

    override func windowDidLoad() {
        super.windowDidLoad()
        drawElementJSON.delegate = self
        spinnerOne.spinnerDelegate = self
        spinnerTwo.spinnerDelegate = self
        drawElementJSON.automaticQuoteSubstitutionEnabled = false
        simpleRenderView.variables = self.variables
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
                variableKeyTwo : spinnerTwo.spinnerValue
            ]
        }
    }
    
    var variableKey1:String = InitialKeyOne
    var variableKey2:String = InitialKeyTwo
}
