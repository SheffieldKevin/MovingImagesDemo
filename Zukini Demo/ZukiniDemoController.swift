//  ZukiniDemoController.swift
//  Zukini Demo
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

enum JSONSegment: Int {
    //    case Setup = 0, Process, DrawInstructions, Finalize, Variables
    case Setup = 0, Process, DrawInstructions, Finalize
    static var firstSegment = JSONSegment.Setup

    private static var firstValue = Setup.rawValue
    private static var lastValue = Finalize.rawValue
    
    var stringValue: String {
        get {
            switch (self) {
            case Setup:
                return "setup"
            case Process:
                return "process"
            case DrawInstructions:
                return "drawinstructions"
            case Finalize:
                return "finalize"
//            case Variables:
//                return "variables"
            }
        }
    }

    init?(stringValue:String) {
        var foundSegment: JSONSegment? = .None
        for index in JSONSegment.firstValue...JSONSegment.lastValue {
            let segment = JSONSegment(rawValue: index)!
            if segment.stringValue == stringValue {
                foundSegment = segment
                break
            }
        }
        
        if let segment = foundSegment {
            self = segment
        }
        else {
            return nil
        }
    }

    func next() -> JSONSegment? {
        return JSONSegment(rawValue: self.rawValue + 1)
    }
}

class ZukiniDemoController: NSWindowController, NSTextViewDelegate,
                            NSWindowDelegate, SpinnerDelegate {
    static let variableDefinitions = "variabledefinitions"

    var jsonSegmentStrings: [Int:String] = [:]
    var lastSelectedSegment: Int = JSONSegment.Setup.rawValue

    // MARK: @IBOutlets
    @IBOutlet var jsonTextView: NSTextView!
    
    @IBOutlet weak var rendererView: ZukiniRendererView!
    
    @IBOutlet weak var spinnerOne: SpinnerController!
    @IBOutlet weak var spinnerTwo: SpinnerController!
    @IBOutlet weak var spinnerThree: SpinnerController!
    @IBOutlet weak var spinnerFour: SpinnerController!
    @IBOutlet weak var exampleList: NSPopUpButton!
    @IBOutlet weak var addSpinner: NSButton!
    @IBOutlet weak var removeSpinner: NSButton!
    @IBOutlet weak var commandSegments: NSSegmentedControl!
    
    // MARK: @IBActions
    @IBAction func addSpinner(sender: AnyObject) {
        for spinner in spinners {
            if spinner.view.hidden {
                spinner.view.hidden = false
                self.spinnerValueChanged(sender: spinner)
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
    
    @IBAction func exampleSelected(sender: AnyObject) {
        let popup = sender as! NSPopUpButton
        
        if let selectedTitle = popup.titleOfSelectedItem {
            let filePath = exampleNameToFilePath(selectedTitle,
                prefix: "renderer_")
            if let dictionary = readJSONFromFile(filePath) {
                configureWithJSONDict(dictionary)
            }
        }
    }
    
    @IBAction func exportJSON(#sender: AnyObject) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["public.json"]
        savePanel.beginSheetModalForWindow(window!, completionHandler: { result in
            if result == NSModalResponseOK {
                let theDict = self.createDictionary()
                if let filePath = savePanel.URL!.path {
                    writeJSONToFile(theDict, filePath: filePath)
                }
                else {
                    println("Invalid file path for exporting moving images source")
                }
            }
        })
    }
    
    @IBAction func importJSON(#sender: AnyObject) {
        let openPanel = NSOpenPanel()
        // openPanel.directoryURL = Optional.None
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(window!, completionHandler: { result in
            if result == NSModalResponseOK {
                self.configureWithJSONFile(openPanel.URLs[0] as? NSURL)
            }
            else {
                println("Invalid file path for importing moving images source")
            }
        })
    }

    @IBAction func selectSegmentCommand(#sender: AnyObject) {
        if let theText = jsonTextView.string {
            jsonSegmentStrings[lastSelectedSegment] = theText
        }
        lastSelectedSegment = commandSegments.selectedSegment
        if let theText = jsonSegmentStrings[lastSelectedSegment] {
            jsonTextView.string = jsonSegmentStrings[lastSelectedSegment]
        }
        else {
            jsonTextView.string = ""
        }
    }

    // MARK: NSTextViewDelegate protocol methods.
    func textDidChange(notification: NSNotification) {
        if let theText = jsonTextView.string {
            jsonSegmentStrings[lastSelectedSegment] = theText
            if lastSelectedSegment == JSONSegment.DrawInstructions.rawValue {
                rendererView.drawDictionary = createDictionaryFromJSONString(theText)
                rendererView.needsDisplay = true
            }
        }
    }
    
    // MARK: Internal properties - bindings in Interface Builder
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
        
        // Setup the spinner controls.
        spinners.append(spinnerOne)
        spinners.append(spinnerTwo)
        spinners.append(spinnerThree)
        spinners.append(spinnerFour)
        
        for spinner in spinners {
            spinner.delegate = self
        }
        // drawElementJSON.delegate = self
        jsonTextView.automaticQuoteSubstitutionEnabled = false
        jsonTextView.font = NSFont(name: "Menlo-Regular", size: 11)
        jsonTextView.textColor = NSColor(deviceWhite: 0.95, alpha: 1.0)
        jsonTextView.backgroundColor = NSColor(deviceWhite: 0.25, alpha: 1.0)
        jsonTextView.selectedTextAttributes = [
            NSBackgroundColorAttributeName : NSColor.lightGrayColor(),
            NSForegroundColorAttributeName : NSColor.blackColor()
        ]
        rendererView.makeNewRenderer(miContext: miContext)
        
        exampleList.addItemsWithTitles(listOfExamples(prefix: "renderer_"))
        self.exampleSelected(exampleList)
        let jsonString = jsonSegmentStrings[JSONSegment.DrawInstructions.rawValue]
        if let jsonString = jsonString {
            rendererView.drawDictionary = createDictionaryFromJSONString(jsonString)
        }
    }
    
    // MARK: Private methods

    private func configureWithJSONFile(fileURL: NSURL?) {
        if let theURL = fileURL,
            let thePath = theURL.path,
            let jsonDict = readJSONFromFile(thePath) {
                self.configureWithJSONDict(jsonDict)
        }
        else {
            println("Invaid JSON file: \(fileURL)")
        }
    }
    
    private func stringForCurrentSegment() -> String? {
        return jsonSegmentStrings[commandSegments.selectedSegment]
    }

    private func createDictionary() -> [String:AnyObject] {
        // TODO: Needs rewriting from the MovingImages Demo version.
        var jsonDict:[String:AnyObject] = [:]
        jsonDict[MIJSONPropertyDrawInstructions] =
            createDictionaryFromJSONString(jsonTextView.string!)
        var variablesArray = [[String:AnyObject]]()
        for spinner in spinners {
            if !spinner.view.hidden {
                variablesArray.append(spinner.spinnerDictionary())
            }
        }
        jsonDict[self.dynamicType.variableDefinitions] = variablesArray
        var currentSegment: JSONSegment? = JSONSegment.firstSegment
        while currentSegment != nil {
            let theSegment = currentSegment!
            jsonDict[theSegment.stringValue] = createDictionaryFromJSONString(
                                jsonSegmentStrings[theSegment.rawValue]!)
            currentSegment = theSegment.next()
        }
        return jsonDict
    }

    private func configureWithJSONDict(jsonDict: [String:AnyObject]) {
        var currentSegment: JSONSegment? = JSONSegment.firstSegment
        while currentSegment != nil {
            let theSegment = currentSegment!
            jsonSegmentStrings[theSegment.rawValue] =
                    makePrettyJSONFromJSONObject(jsonDict[theSegment.stringValue])
            currentSegment = theSegment.next()
        }
        for spinner in spinners {
            spinner.view.hidden = true
        }

        if let varDefs:AnyObject =
            jsonDict[ZukiniDemoController.variableDefinitions],
            let variableDefs = varDefs as? [AnyObject]
        {
            for (index, variableDefinition) in enumerate(variableDefs) {
                if let variableDef = variableDefinition as? [String:AnyObject] {
                    spinners[index].configureSpinner(dictionary: variableDef)
                    spinners[index].view.hidden = false
                }
            }
            
        }
        rendererView.needsDisplay = true
        updateSpinnersEditingControls()
    }
    
    private func evaluateEnabledStateForAddSpinnersButtons() -> Bool {
        var numberOfSpinners = 0
        for spinner in spinners {
            if !spinner.view.hidden {
                numberOfSpinners++
            }
        }
        return !(numberOfSpinners == maximumNumberOfSpinners)
    }
    
    private func evaluateEnabledStateForRemoveSpinnersButton() -> Bool {
        var numberOfSpinners = 0
        for spinner in spinners {
            if spinner.view.hidden {
                numberOfSpinners++
            }
        }
        return !(numberOfSpinners == 4)
    }
    
    private func updateSpinnersEditingControls() {
        addSpinnersEnabled = evaluateEnabledStateForAddSpinnersButtons()
        removeSpinnersEnabled = evaluateEnabledStateForRemoveSpinnersButton()
    }
    
    // MARK: Private properties
    private var spinners = [SpinnerController]()
    
    private var variables:[String:AnyObject] {
        get {
            var theDictionary:[String:AnyObject] = [
                MIJSONKeyWidth : rendererView.drawWidth,
                MIJSONKeyHeight : rendererView.drawHeight
            ]
            for spinner in spinners {
                if !spinner.view.hidden {
                    theDictionary[spinner.variableKey] = spinner.spinnerValue
                }
            }
            return theDictionary
        }
    }

    private var miContext:MIContext = MIContext()
}

extension ZukiniDemoController: SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) {
        rendererView.variables = self.variables
        rendererView.needsDisplay = true
    }
}

extension ZukiniDemoController: NSWindowDelegate {
    func windowDidResize(notification: NSNotification) {
        rendererView.variables = self.variables
    }
}
