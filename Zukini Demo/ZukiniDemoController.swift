//  ZukiniDemoController.swift
//  Zukini Demo
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

enum JSONSegment: Int {
    // case Setup = 0, Process, DrawInstructions, Finalize, Variables
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

    @IBAction func doSetupCommands(#sender: AnyObject) {
        self.performSetupCommands()
    }
    
    @IBAction func doProcessCommands(#sender: AnyObject) {
        self.performProcessCommands(progressHandler: self.progressHandler,
            completionHandler: self.processCompletion)
    }

    @IBAction func doFinalizeCommands(#sender: AnyObject) {
        self.performFinalizeCommands()
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
        rendererView.makeNewRenderer(miContext: self.miContext)
        
        exampleList.addItemsWithTitles(listOfExamples(prefix: "renderer_"))
        self.exampleSelected(exampleList)
        let jsonString = jsonSegmentStrings[JSONSegment.DrawInstructions.rawValue]
        if let jsonString = jsonString {
            rendererView.drawDictionary = createDictionaryFromJSONString(jsonString)
        }
    }
    
    // MARK: Private methods
    
    // Returns true on success.
    
    private func performJSONCommands(jsonString: String?) -> Bool {
        if let jsonString = jsonString,
            let jsonDict = createDictionaryFromJSONString(jsonString) {
            let resultDict = MIMovingImagesHandleCommands(self.miContext,
                jsonDict, .None, .None)
            return MIGetErrorCodeFromReplyDictionary(resultDict) == MIReplyErrorEnum.NoError
        }
        return false
    }
    
    private func progressHandler(commandIndex: NSInteger) -> Void {
        dispatch_async(dispatch_get_main_queue(), { self.rendererView.needsDisplay = true })
    }
    
    private func processCompletion(replyDictionary: [NSObject:AnyObject]) -> Void {
        processingCommands = false
    }

    private func performSetupCommands() -> Bool {
        let result = performJSONCommands(jsonSegmentStrings[JSONSegment.Setup.rawValue])
        self.canProcesss = true
        return result
    }

    private func performFinalizeCommands() -> Bool {
        self.canProcesss = false
        return performJSONCommands(jsonSegmentStrings[JSONSegment.Finalize.rawValue])
    }

    private func performProcessCommands(progressHandler: MIProgressHandler? = .None,
                        completionHandler: MICommandCompletionHandler? = .None) -> Bool {
        if let jsonString = jsonSegmentStrings[JSONSegment.Process.rawValue],
            let jsonDict = createDictionaryFromJSONString(jsonString)
        {
            let runsAsync = jsonDict[MIJSONKeyRunAsynchronously] as? Bool ?? false
            processingCommands = true
            let resultDict = MIMovingImagesHandleCommands(self.miContext, jsonDict,
                progressHandler, completionHandler)
            if !runsAsync {
                processingCommands = false
            }
            return MIGetErrorCodeFromReplyDictionary(resultDict) == MIReplyErrorEnum.NoError
        }
        return false
    }

    private func configureWithJSONFile(fileURL: NSURL?) {
        if let theURL = fileURL,
            let thePath = theURL.path,
            let jsonDict = readJSONFromFile(thePath) {
                self.configureWithJSONDict(jsonDict)
        }
        else {
            println("Invalid JSON file: \(fileURL)")
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
            if theSegment == JSONSegment.DrawInstructions {
                rendererView.drawDictionary = jsonDict[theSegment.stringValue] as? [String:AnyObject]
            }
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
            rendererView.variables = self.variables
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
    private let maximumNumberOfSpinners = 4
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
    
    private var lastEvaluatedVariables:[String:AnyObject]?
    
    private var processingCommands = false
    private var canProcesss = false
}

extension ZukiniDemoController: SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) {
        if let previouslyEvaluated = lastEvaluatedVariables {
            self.miContext.dropVariablesDictionary(previouslyEvaluated)
        }
        lastEvaluatedVariables = self.variables
        self.miContext.appendVariables(lastEvaluatedVariables)
        rendererView.needsDisplay = true
    }
}

extension ZukiniDemoController: NSWindowDelegate {
    func windowDidResize(notification: NSNotification) {
        rendererView.variables = self.variables
    }
}
