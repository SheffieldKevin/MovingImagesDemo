//  ZukiniDemoController.swift
//  Zukini Demo
//
//  Copyright (c) 2015 Zukini Ltd.

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

class ZukiniDemoController: NSWindowController {
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
    
    @IBOutlet weak var movieInput1: NSPopUpButton!
    @IBOutlet weak var movieInput2: NSPopUpButton!
    @IBOutlet weak var imageInput1: NSPopUpButton!
    @IBOutlet weak var imageInput2: NSPopUpButton!
    
    @IBOutlet weak var doSetupButton: NSButton!
    @IBOutlet weak var processButton: NSButton!
    @IBOutlet weak var finalizeButton: NSButton!
    @IBOutlet weak var assignDestinationButton: NSButton!
    
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

        if self.canDoFinalize {
            self.doFinalizeCommands(sender: self)
        }

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
            completionHandler: self.processCompletionHandler)
    }

    @IBAction func doFinalizeCommands(#sender: AnyObject) {
        self.performFinalizeCommands()
    }

    @IBAction func exportDestination(#sender: AnyObject) {
        let chooseFolderPanel = NSOpenPanel.new()
        chooseFolderPanel.canChooseDirectories = true
        chooseFolderPanel.canChooseFiles = false
        chooseFolderPanel.beginSheetModalForWindow(window!, completionHandler:
        { result in
            if result == NSModalResponseOK {
                if let theURL = chooseFolderPanel.URLs[0] as? NSURL,
                    let path = theURL.path
                {
                    self.exportFolderLocation = path
                }
                else {
                    println("Invalid file path for exporting moving images source")
                }
            }
        })
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
        let moviesList = ZukiniDemoController.listOfMovies()
        movieInput1.addItemsWithTitles(moviesList)
        movieInput2.addItemsWithTitles(moviesList)
        let firstMoviePath = movieNameToPath(moviesList.first!)
        movie1Filepath = firstMoviePath
        movie2Filepath = firstMoviePath
        
        let imagesList = ZukiniDemoController.listOfImages()
        imageInput1.addItemsWithTitles(imagesList)
        imageInput2.addItemsWithTitles(imagesList)
        let firstImagePath = imageNameToPath(imagesList.first!)
        image1Filepath = firstImagePath
        image2Filepath = firstImagePath

        self.exampleSelected(exampleList)
        let jsonString = jsonSegmentStrings[JSONSegment.DrawInstructions.rawValue]
        if let jsonString = jsonString {
            rendererView.drawDictionary = createDictionaryFromJSONString(jsonString)
        }
        
        self.exportFolderLocation = self.exportFolderLocation.stringByExpandingTildeInPath
    }

    // MARK: Private methods
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
    
    private func processCompleted() -> Void {
        self.processingCommands = false
        // self.canProcess = false
        self.updateDoCommandsButtons()
        self.rendererView.needsDisplay = true
    }
    
    private func processCompletionHandler(replyDictionary: [NSObject:AnyObject]) -> Void {
        processCompleted()
    }

    private func performSetupCommands() -> Bool {
        self.updateVariables()
        let result = performJSONCommands(jsonSegmentStrings[JSONSegment.Setup.rawValue])
        self.hasSetupRun = true
        self.updateDoCommandsButtons()
        return result
    }

    private func performFinalizeCommands() -> Bool {
        self.updateVariables()
        let result = performJSONCommands(jsonSegmentStrings[JSONSegment.Finalize.rawValue])
        self.hasSetupRun = false
        self.updateDoCommandsButtons()
        return result
    }

    private func performProcessCommands(progressHandler: MIProgressHandler? = .None,
        completionHandler: MICommandCompletionHandler? = .None) -> Bool {

        var runsAsync:Bool = false
        var result:Bool = false
        self.updateVariables()
        if self.canProcess {
            let jsonString = jsonSegmentStrings[JSONSegment.Process.rawValue]            
            if let jsonDict = createDictionaryFromJSONString(jsonString)
            {
                self.processingCommands = true
                self.updateDoCommandsButtons()
                runsAsync = jsonDict[MIJSONKeyRunAsynchronously] as? Bool ?? false
                let resultDict = MIMovingImagesHandleCommands(self.miContext, jsonDict,
                    progressHandler, completionHandler)
                result = MIGetErrorCodeFromReplyDictionary(resultDict) == MIReplyErrorEnum.NoError
            }
        }

        if !runsAsync {
            processCompleted()
        }
        return result
    }

    private class func listOfMovies() -> [String] {
        let bundle = NSBundle(forClass: ZukiniDemoController.self)
        let moviePaths = bundle.pathsForResourcesOfType("mov", inDirectory: "Movies")
        let movies = moviePaths.map() { filePath -> String in
            return filePath.lastPathComponent.stringByDeletingPathExtension
        }
        return movies
    }

    private class func listOfImages() -> [String] {
        let bundle = NSBundle(forClass: self)
        let moviePaths = bundle.pathsForResourcesOfType("jpg", inDirectory: "Pictures")
        
        let examples = moviePaths.map() {
            filePath -> String in return filePath.lastPathComponent.stringByDeletingPathExtension
        }
        return examples
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

    private func updateVariables() -> Void {
        if let previouslyEvaluated = lastEvaluatedVariables {
            self.miContext.dropVariablesDictionary(previouslyEvaluated)
        }
        self.lastEvaluatedVariables = self.variables
        self.miContext.appendVariables(lastEvaluatedVariables)
    }
    
    private func configureWithJSONDict(jsonDict: [String:AnyObject]) {
        var currentSegment: JSONSegment? = JSONSegment.firstSegment
        while currentSegment != nil {
            let theSegment = currentSegment!
            let prettyJSON = makePrettyJSONFromJSONObject(jsonDict[theSegment.stringValue]) ?? ""
            jsonSegmentStrings[theSegment.rawValue] = prettyJSON
            if theSegment == JSONSegment.DrawInstructions {
                rendererView.drawDictionary = jsonDict[theSegment.stringValue] as? [String:AnyObject]
            }
            if theSegment.rawValue == self.lastSelectedSegment {
                jsonTextView.string = jsonSegmentStrings[lastSelectedSegment]
            }
            currentSegment = theSegment.next()
        }
        for spinner in spinners {
            spinner.view.hidden = true
        }

        self.exportFileName = jsonDict["exportfilename"] as? String

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

            // rendererView.variables = self.variables
            self.updateVariables()
        }
        
        
        self.hasSetupRun = false
        self.canProcess = false
        self.canDoFinalize = false
        
        if self.emptySetup {
            self.canDoSetup = false
            self.canProcess = true
            self.canDoFinalize = true
        }
        self.updateDoCommandsButtons()

        rendererView.needsDisplay = true
        self.updateSpinnersEditingControls()
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
    private var emptySetup: Bool {
        get {
            return self.jsonSegmentStrings[JSONSegment.Setup.rawValue]!.isEmpty
        }
    }

    private var exportFileName:String?
    private var hasSetupRun = false

    dynamic private var canDoSetup = false
    dynamic private var canProcess = false
    dynamic private var canDoFinalize = false

    private var processingCommands = false

    private func updateDoCommandsButtons() -> Void {
        self.canDoSetup = !(self.hasSetupRun || self.emptySetup)
        self.canProcess = (self.hasSetupRun || self.emptySetup) && !self.processingCommands
        self.canDoFinalize = (self.hasSetupRun || self.emptySetup) && !self.processingCommands
    }
    
    private var exportFolderLocation = "~/Desktop"
    private let maximumNumberOfSpinners = 4
    private var spinners = [SpinnerController]()
    
    private var movie1Filepath:String = ""
    private var movie2Filepath:String = ""
    private var image1Filepath:String = ""
    private var image2Filepath:String = ""
    private var destination:String = ""
    
    private var variables:[String:AnyObject] {
        get {
            var theDictionary:[String:AnyObject] = [
                MIJSONKeyWidth : rendererView.drawWidth,
                MIJSONKeyHeight : rendererView.drawHeight,
                "movie1path" : movie1Filepath,
                "movie2path" : movie2Filepath,
                "image1path" : image1Filepath,
                "image2path" : image2Filepath,
            ]
            for spinner in spinners {
                if !spinner.view.hidden {
                    theDictionary[spinner.variableKey] = spinner.spinnerValue
                }
            }
            
            if let fileName = self.exportFileName
            {
                let filePath = self.exportFolderLocation.stringByAppendingPathComponent(fileName)
                theDictionary["exportfilepath"] = filePath
            }
            return theDictionary
        }
    }

    private var miContext:MIContext = MIContext()
    
    private var lastEvaluatedVariables:[String:AnyObject]?
}

// MARK: ZukiniDemoController extension managing resources.
extension ZukiniDemoController {
    private func movieNameToPath(name: String) -> String {
        let fileName = name.stringByAppendingPathExtension("mov")!
        let moviePath = "Movies".stringByAppendingPathComponent(fileName)
        let theBundle = NSBundle(forClass: self.dynamicType)
        return theBundle.resourcePath!.stringByAppendingPathComponent(moviePath)
    }
    
    @IBAction func movieSelected(sender: AnyObject) {
        let popup = sender as! NSPopUpButton
        if let selectedTitle = popup.titleOfSelectedItem {
            let filePath = movieNameToPath(selectedTitle)
            if popup == movieInput1 {
                movie1Filepath = filePath
            }
            else {
                movie2Filepath = filePath
            }
        }
    }
    
    private func imageNameToPath(name: String) -> String {
        let fileName = name.stringByAppendingPathExtension("jpg")!
        let moviePath = "Images".stringByAppendingPathComponent(fileName)
        let theBundle = NSBundle(forClass: self.dynamicType)
        return theBundle.resourcePath!.stringByAppendingPathExtension(moviePath)!
    }
    
    @IBAction func imageSelected(sender: AnyObject) {
        let popup = sender as! NSPopUpButton
        if let selectedTitle = popup.titleOfSelectedItem {
            let filePath = imageNameToPath(selectedTitle)
            if popup == imageInput1 {
                image1Filepath = filePath
            }
            else {
                image2Filepath = filePath
            }
        }
    }
}

// MARK: ZukiniDemoController. Delegate protocol extensions.
extension ZukiniDemoController: SpinnerDelegate {
    func spinnerValueChanged(#sender: SpinnerController) {
        self.updateVariables()
        self.performProcessCommands(progressHandler: self.progressHandler,
            completionHandler: self.processCompletionHandler)
    }
}

extension ZukiniDemoController: NSWindowDelegate {
    func windowDidResize(notification: NSNotification) {
        self.updateVariables()
        self.performProcessCommands(progressHandler: self.progressHandler,
            completionHandler: self.processCompletionHandler)
    }
}

extension ZukiniDemoController: NSTextViewDelegate {
    func textDidChange(notification: NSNotification) {
        if let theText = jsonTextView.string {
            jsonSegmentStrings[lastSelectedSegment] = theText
            if lastSelectedSegment == JSONSegment.DrawInstructions.rawValue {
                rendererView.drawDictionary = createDictionaryFromJSONString(theText)
                rendererView.needsDisplay = true
            }
        }
    }
}
