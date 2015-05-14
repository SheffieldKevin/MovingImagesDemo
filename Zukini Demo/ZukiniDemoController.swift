//  ZukiniDemoController.swift
//  Zukini Demo
//  Copyright (c) 2015 Kevin Meaney

import Cocoa
import MovingImages

class ZukiniDemoController: NSWindowController {
    static let variableDefinitions = "variabledefinitions"
    
    static let setupDictionaryKey = "setup"
    static let processDictionaryKey = "process"
    static let drawInstructionsDictionaryKey = "drawinstructions"
    static let finalizeDictionaryKey = "finalize"
    static let variablesKey = "variables"

    static let segmentTagDictionary: [Int:String] = [
        0 : setupDictionaryKey,
        1 : processDictionaryKey,
        2 : drawInstructionsDictionaryKey,
        3 : finalizeDictionaryKey,
        4 : variablesKey
    ]
    
    // MARK: @IBOutlets
    @IBOutlet var jsonTextView: NSTextView!
    
    @IBOutlet weak var simpleRenderView: SimpleRendererView!
    
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
                if let theURL = openPanel.URLs[0] as? NSURL,
                    let thePath = theURL.path {
                        if let jsonDict = readJSONFromFile(thePath) {
                            self.configureWithJSONDict(jsonDict)
                        }
                        else {
                            println("Invaid JSON dictionary")
                        }
                }
                else {
                    println("Invalid file path for importing moving images source")
                }
            }
        })
    }
    
    @IBAction func selectSegmentCommands(#sender: AnyObject) {
        
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
        // drawElementJSON.delegate = self
        jsonTextView.automaticQuoteSubstitutionEnabled = false
        jsonTextView.font = NSFont(name: "Menlo-Regular", size: 11)
        jsonTextView.textColor = NSColor(deviceWhite: 0.95, alpha: 1.0)
        jsonTextView.backgroundColor = NSColor(deviceWhite: 0.25, alpha: 1.0)
        jsonTextView.selectedTextAttributes = [
            NSBackgroundColorAttributeName : NSColor.lightGrayColor(),
            NSForegroundColorAttributeName : NSColor.blackColor()
        ]
        // simpleRenderView.variables = self.variables
        if let theImage = createCGImage("Sculpture", fileExtension: "jpg") {
            simpleRenderView.assignImage(theImage, identifier: "Sculpture")
        }
        
        exampleList.addItemsWithTitles(listOfExamples(prefix: "renderer_"))
        self.exampleSelected(exampleList)
    }
    
    // MARK: Private methods

    // makePrettyJSONFromDictionary
    private func stringForCurrentSegment() -> String? {
        // segmentTagDictionary
        let jsonObject:AnyObject?
        switch commandSegments.tag {
            case 0:
                jsonObject = setupDictionary
            
            case 1:
                jsonObject = processDictionary
            
            case 2:
                jsonObject = drawDictionary
            
            case 3:
                jsonObject = finalizeDictionary

            case 4:
                jsonObject = variablesArray
            
            default:
                jsonObject = .None
        }
        
        let jsonString:String?
        if let jsonObject: AnyObject = jsonObject {
            jsonString = makePrettyJSONFromJSONObject(jsonObject)
        }
        else {
            jsonString = .None
        }
        return jsonString
    }

    private func createDictionary() -> [String:AnyObject] {
        var jsonDict = [String:AnyObject]()
        jsonDict[MIJSONPropertyDrawInstructions] =
            createDictionaryFromJSONString(jsonTextView.string!)
        var variablesArray = [[String:AnyObject]]()
        for spinner in spinners {
            if !spinner.view.hidden {
                variablesArray.append(spinner.spinnerDictionary())
            }
        }
        jsonDict[self.dynamicType.variableDefinitions] = variablesArray
        return jsonDict
    }

    private func configureWithJSONDict(jsonDictionary: [String:AnyObject]) {
        setupDictionary = .None
        if let theSetup: AnyObject = jsonDictionary[ZukiniDemoController.setupDictionaryKey]  {
            setupDictionary = theSetup as? [String:AnyObject]
        }
        
        processDictionary = .None
        if let process: AnyObject = jsonDictionary[ZukiniDemoController.processDictionaryKey]  {
            processDictionary = process as? [String:AnyObject]
        }

        drawDictionary = .None
        if let draw: AnyObject = jsonDictionary[ZukiniDemoController.drawInstructionsDictionaryKey] {
            drawDictionary = draw as? [String:AnyObject]
        }
        
        finalizeDictionary = .None
        if let finalize: AnyObject = jsonDictionary[ZukiniDemoController.finalizeDictionaryKey] {
            finalizeDictionary = finalize as? [String:AnyObject]
        }
        
        variablesArray = .None
        if let varArray: AnyObject = jsonDictionary[ZukiniDemoController.variablesKey] {
            variablesArray = varArray as? [[String:AnyObject]]
        }
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
                MIJSONKeyWidth : simpleRenderView.drawWidth,
                MIJSONKeyHeight : simpleRenderView.drawHeight
            ]
            for spinner in spinners {
                if !spinner.view.hidden {
                    theDictionary[spinner.variableKey] = spinner.spinnerValue
                }
            }
            return theDictionary
        }
    }
    
    private var setupDictionary:[String:AnyObject]?
    private var processDictionary:[String:AnyObject]?
    private var drawDictionary:[String:AnyObject]?
    private var finalizeDictionary:[String:AnyObject]?
    private var variablesArray:[[String:AnyObject]]?
}

extension ZukiniDemoController: SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) {
        simpleRenderView.variables = self.variables
        simpleRenderView.needsDisplay = true
    }
}

extension ZukiniDemoController: NSWindowDelegate {
    func windowDidResize(notification: NSNotification) {
        simpleRenderView.variables = self.variables
    }
}
