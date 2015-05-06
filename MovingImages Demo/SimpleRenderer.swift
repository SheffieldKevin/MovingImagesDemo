//  SimpleRenderer.swift
//  MovingImages Demo
//  Copyright (c) 2015 Kevin Meaney. 30/03/2015.

import Cocoa
import MovingImages


class SimpleRendererWindowController:NSWindowController, NSTextViewDelegate,
                                     NSWindowDelegate, SpinnerDelegate {
    static let variableDefinitions = "variabledefinitions"
    // MARK: @IBOutlets
    @IBOutlet var drawElementJSON: NSTextView!
    
    @IBOutlet weak var simpleRenderView: SimpleRendererView!

    @IBOutlet weak var spinnerOne: SpinnerController!
    @IBOutlet weak var spinnerTwo: SpinnerController!
    @IBOutlet weak var spinnerThree: SpinnerController!
    @IBOutlet weak var spinnerFour: SpinnerController!
    @IBOutlet weak var exampleList: NSPopUpButton!
    @IBOutlet weak var addSpinner: NSButton!
    @IBOutlet weak var removeSpinner: NSButton!

    // MARK: @IBActions
    @IBAction func addSpinner(sender: AnyObject) {
        for spinner in spinners {
            if spinner.view.hidden {
                spinner.view.hidden = false
                break
            }
        }
        updateSpinnersEditingControls()
    }
    
    @IBAction func removeSpinner(sender: AnyObject) {
        for spinner in reverse(spinners) {
            if !spinner.view.hidden {
                spinner.view.hidden = true
                break
            }
        }
        updateSpinnersEditingControls()
    }

    @IBAction func saveAsJSON(sender: AnyObject) {
        var jsonDict = [String:AnyObject]()
        jsonDict[MIJSONPropertyDrawInstructions] =
                    createDictionaryFromJSONString(drawElementJSON.string!)
        var variablesArray = [[String:AnyObject]]()
        for spinner in spinners {
            if !spinner.view.hidden {
                var variablesDict = [String:AnyObject]()
                variablesDict["maxvalue"] = spinner.maxValue
                variablesDict["minvalue"] = spinner.minValue
                variablesDict["defaultvalue"] = spinner.spinnerValue
                variablesArray.append(variablesDict)
            }
        }
        jsonDict[SimpleRendererWindowController.variableDefinitions] = variablesArray
        writeJSONToFile(jsonDict, filePath: "/Users/ktam/Desktop/simple_renderer_newimage.json")
    }
    
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
            for spinner in spinners {
                spinner.view.hidden = true
            }
            drawElementJSON.string = jsonString
            if let theDict = createDictionaryFromJSONString(jsonString) {
                simpleRenderView.drawDictionary = theDict
            }
            
            if let variableDefinitions:AnyObject =
                dictionary[SimpleRendererWindowController.variableDefinitions],
               let variableDefs = variableDefinitions as? [AnyObject]
            {
                for (index, variableDefinition) in enumerate(variableDefs) {
                    if let variableDef = variableDefinition as? [String:AnyObject] {
                        spinners[index].configureSpinner(dictionary: variableDef)
                        spinners[index].view.hidden = false
                    }
                }

            }
            simpleRenderView.needsDisplay = true
        }
        simpleRenderView.variables = self.variables
        updateSpinnersEditingControls()
    }

    // MARK: Internal properties
    
    dynamic var addSpinnersEnabled = true
    dynamic var removeSpinnersEnabled = true
    
    // MARK: Private properties
    private let maximumNumberOfSpinners = 4

    // MARK: NSWindowController overrides.
    override func windowDidLoad() {
        super.windowDidLoad()
        if let theWindow = self.window {
            theWindow.backgroundColor = NSColor(deviceWhite: 0.15, alpha: 1.0)
        }
        spinners.append(spinnerOne)
        spinners.append(spinnerTwo)
        spinners.append(spinnerThree)
        spinners.append(spinnerFour)

        for spinner in spinners {
            spinner.delegate = self
        }
        drawElementJSON.delegate = self
        drawElementJSON.automaticQuoteSubstitutionEnabled = false
        drawElementJSON.font = NSFont(name: "Menlo-Regular", size: 11)
        drawElementJSON.textColor = NSColor(deviceWhite: 0.95, alpha: 1.0)
        drawElementJSON.backgroundColor = NSColor(deviceWhite: 0.25, alpha: 1.0)
        drawElementJSON.selectedTextAttributes = [
            NSBackgroundColorAttributeName : NSColor.lightGrayColor(),
            NSForegroundColorAttributeName : NSColor.blackColor()
        ]
        // simpleRenderView.variables = self.variables
        if let theImage = createCGImage("Sculpture", fileExtension: "jpg") {
            simpleRenderView.assignImage(theImage, identifier: "Sculpture")
        }
        
        exampleList.addItemsWithTitles(listOfExamples(prefix: "simple_renderer_"))
        self.exampleSelected(exampleList)
    }
    
    // MARK: NSWindowDelegate protocol methods.
    func windowDidResize(notification: NSNotification) {
        simpleRenderView.variables = self.variables
    }
    
    // MARK: NSTextViewDelegate protocol methods.
    func textDidChange(notification: NSNotification) {
        if let jsonText = drawElementJSON.string,
            let theDict = createDictionaryFromJSONString(jsonText) {
            simpleRenderView.drawDictionary = theDict
            simpleRenderView.variables = self.variables
            simpleRenderView.needsDisplay = true
        }
    }
    
    // MARK: SpinnerDelegate
    func spinnerValueChanged(#sender: SpinnerController) {
        simpleRenderView.variables = self.variables
        simpleRenderView.needsDisplay = true
    }
    
    // MARK: Private methods
    func evaluateEnabledStateForAddSpinnersButtons() -> Bool {
        var numberOfSpinners = 0
        for spinner in spinners {
            if !spinner.view.hidden {
                numberOfSpinners++
            }
        }
        return !(numberOfSpinners == maximumNumberOfSpinners)
    }

    func evaluateEnabledStateForRemoveSpinnersButton() -> Bool {
        var numberOfSpinners = 0
        for spinner in spinners {
            if spinner.view.hidden {
                numberOfSpinners++
            }
        }
        return !(numberOfSpinners == 4)
    }

    func updateSpinnersEditingControls() {
        addSpinnersEnabled = evaluateEnabledStateForAddSpinnersButtons()
        removeSpinnersEnabled = evaluateEnabledStateForRemoveSpinnersButton()
    }
    
    // MARK: Private properties
    private var spinners = [SpinnerController]()
    
    private var variables:[String:AnyObject] {
        get {
            var theDictionary:[String:AnyObject] = [
                MIJSONKeyWidth : simpleRenderView.frame.width - 8,
                MIJSONKeyHeight : simpleRenderView.frame.height - 8
            ]
            for spinner in spinners {
                if !spinner.view.hidden {
                    theDictionary[spinner.variableKey] = spinner.spinnerValue
                }
            }
            return theDictionary
        }
    }
}
