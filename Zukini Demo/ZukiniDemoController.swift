//  ZukiniDemoController.swift
//  Zukini Demo
//
//  Copyright (c) 2015 Zukini Ltd.

import Cocoa
import MovingImages

enum JSONSegment: Int, Equatable {
    case Setup = 0, Process, DrawInstructions, Finalize, Variables
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
            case Variables:
                return "variables"
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

func ==(lhs: JSONSegment, rhs: JSONSegment) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

class ZukiniDemoController: NSWindowController {
//    static let variableDefinitions = "variabledefinitions"
    static let exportFolderPathDefaultsKey = "exportfolderpath"
    static let windowWidthKey = "windowwidth"
    static let windowHeightKey = "windowheight"
    static let windowXKey = "windowx"
    static let windowYKey = "windowy"
    static let windowFullScreenKey = "windowfullscreen"
    
    static let windowWidth = 1278
    static let windowHeight = 678
    static let windowX = 0
    static let windowY = 20

    var jsonSegmentStrings: [Int:String] = [:]
    var lastSelectedSegment = JSONSegment.Setup

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
    
    @IBOutlet weak var exportMediaFilename: NSTextField!
    
    @IBOutlet weak var doSetupButton: NSButton!
    @IBOutlet weak var processButton: NSButton!
    @IBOutlet weak var finalizeButton: NSButton!
    @IBOutlet weak var assignDestinationButton: NSButton!
    @IBOutlet weak var openFile: NSButton!
    
    // MARK: @IBActions
    @IBAction func addSpinner(sender: AnyObject) {
        for spinner in spinners {
            if spinner.view.hidden {
                spinner.view.hidden = false
                self.spinnerValueChanged()
                break
            }
        }
        self.updateSpinnersEditingControls()
        self.spinnersModified()
    }
    
    @IBAction func removeSpinner(sender: AnyObject) {
        for spinner in spinners.reverse() {
            if !spinner.view.hidden {
                spinner.view.hidden = true
                break
            }
        }
        self.updateSpinnersEditingControls()
        self.spinnersModified()
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
    
    @IBAction func exportJSON(sender sender: AnyObject) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["public.json"]
        savePanel.beginSheetModalForWindow(window!, completionHandler: { result in
            if result == NSModalResponseOK {
                let theDict = self.createDictionary()
                if let filePath = savePanel.URL!.path {
                    writeJSONToFile(theDict, filePath: filePath)
                }
                else {
                    print("Invalid file path for exporting moving images source")
                }
            }
        })
    }
    
    @IBAction func importJSON(sender sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(window!, completionHandler: { result in
            if result == NSModalResponseOK {
                self.configureWithJSONFile(openPanel.URLs[0])
            }
            else {
                print("Invalid file path for importing moving images source")
            }
        })
    }

    @IBAction func selectSegmentCommand(sender sender: AnyObject) {
        if let theText = jsonTextView.string {
            jsonSegmentStrings[lastSelectedSegment.rawValue] = theText
        }
        self.lastSelectedSegment = JSONSegment(rawValue: commandSegments.selectedSegment)!
        if let _ = jsonSegmentStrings[self.lastSelectedSegment.rawValue] {
            jsonTextView.string = jsonSegmentStrings[self.lastSelectedSegment.rawValue]
        }
        else {
            self.jsonTextView.string = ""
        }
        if self.lastSelectedSegment == JSONSegment.Variables {
            self.jsonTextView.editable = false
        }
        else {
            self.jsonTextView.editable = true
        }
    }

    @IBAction func doSetupCommands(sender sender: AnyObject) {
        self.performSetupCommands()
    }
    
    @IBAction func doProcessCommands(sender sender: AnyObject) {
        self.performProcessCommands(self.progressHandler,
            completionHandler: self.processCompletionHandler)
    }

    @IBAction func doFinalizeCommands(sender sender: AnyObject) {
        if self.performFinalizeCommands() && openFile.integerValue != 0 {
            let fileName = self.exportMediaFilename.stringValue
            let folderPath = self.exportFolderLocation
            let filePath = NSString(string: folderPath).stringByAppendingPathComponent(fileName)
            NSWorkspace.sharedWorkspace().openFile(filePath)
        }
    }

    @IBAction func exportDestination(sender sender: AnyObject) {
        let chooseFolderPanel = NSOpenPanel()
        chooseFolderPanel.canChooseDirectories = true
        chooseFolderPanel.canChooseFiles = false
        chooseFolderPanel.canCreateDirectories = true
        chooseFolderPanel.beginSheetModalForWindow(window!, completionHandler:
        { result in
            if result == NSModalResponseOK {
                if let path = chooseFolderPanel.URLs[0].path
                {
                    self.exportFolderLocation = path
                    NSUserDefaults.standardUserDefaults().setObject(path,
                        forKey: ZukiniDemoController.exportFolderPathDefaultsKey)
                }
                else {
                    print("Invalid file path for exporting moving images source")
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
        openFile.toolTip = "Open the movie after it has been generated"
        let attributedString = openFile.attributedTitle.mutableCopy() as! NSMutableAttributedString
        let stringRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(NSForegroundColorAttributeName,
            value: NSColor.whiteColor(), range: stringRange)

        openFile.attributedTitle = attributedString.copy() as! NSAttributedString
        
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
        movieInput2.selectItemAtIndex(1)
        let firstMoviePath = movieNameToPath(moviesList.first!)
        movie1Filepath = firstMoviePath
        movie2Filepath = movieNameToPath(moviesList[1])
        
        self.exampleSelected(exampleList)
        let jsonString = jsonSegmentStrings[JSONSegment.DrawInstructions.rawValue]
        if let jsonString = jsonString {
            rendererView.drawDictionary =
                    createJSONObjectFromJSONString(jsonString) as? [String:AnyObject]
        }
        let folderPath = NSString(string: self.exportFolderLocation).stringByExpandingTildeInPath
        let defaultsDict:[String : AnyObject] =
            [ZukiniDemoController.exportFolderPathDefaultsKey : folderPath,
            ZukiniDemoController.windowWidthKey : ZukiniDemoController.windowWidth,
            ZukiniDemoController.windowHeightKey : ZukiniDemoController.windowHeight,
            ZukiniDemoController.windowXKey : ZukiniDemoController.windowX,
            ZukiniDemoController.windowYKey : ZukiniDemoController.windowY,
            ZukiniDemoController.windowFullScreenKey : false]
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults(defaultsDict)
        if let theWindow = self.window {
            let fullScreen = defaults.boolForKey(ZukiniDemoController.windowFullScreenKey)
            let windowWidth = defaults.integerForKey(ZukiniDemoController.windowWidthKey)
            let windowHeight = defaults.integerForKey(ZukiniDemoController.windowHeightKey)
            let windowX = defaults.integerForKey(ZukiniDemoController.windowXKey)
            let windowY = defaults.integerForKey(ZukiniDemoController.windowYKey)
            let windowSize = CGSize(width: windowWidth, height: windowHeight)
            let windowOrigin = CGPoint(x: windowX, y: windowY)
            theWindow.setFrame(NSRect(origin: windowOrigin, size: windowSize), display: true)
            if fullScreen {
                theWindow.toggleFullScreen(self)
            }
            // println("Window collection Behaviour \(theWindow.collectionBehavior.rawValue)")
        }
        self.updateVariables()
        self.exportFolderLocation = defaults.objectForKey(
                    ZukiniDemoController.exportFolderPathDefaultsKey)! as! String
    }

    // MARK: Private methods
    private func performJSONCommands(jsonString: String?) -> Bool {
        if let jsonString = jsonString,
        let jsonDict = createJSONObjectFromJSONString(jsonString) as? [String:AnyObject]
        {
            let resultDict = MIMovingImagesHandleCommands(self.miContext,
                jsonDict, .None, .None)
            
            let result = MIGetErrorCodeFromReplyDictionary(resultDict) == MIReplyErrorEnum.NoError
            if !result {
                print("Error result: \(resultDict)")
            }
            return result
        }
        return false
    }
    
    private func progressHandler(commandIndex: NSInteger) -> Void {
        dispatch_async(dispatch_get_main_queue(), { self.rendererView.needsDisplay = true })
    }
    
    private func processCompleted() -> Void {
        self.processingCommands = false
        
        self.updateDoCommandsButtons()
        self.rendererView.needsDisplay = true
    }
    
    private func processCompletionHandler(replyDictionary: [NSObject:AnyObject]) -> Void {
        processCompleted()
        let result = MIGetErrorCodeFromReplyDictionary(replyDictionary) == MIReplyErrorEnum.NoError
        if !result {
            print("Error result: \(replyDictionary)")
        }
    }

    private func performSetupCommands() -> Bool {
        self.updateVariables()
        let result = performJSONCommands(jsonSegmentStrings[JSONSegment.Setup.rawValue])
        self.hasSetupRun = true
        self.updateDoCommandsButtons()
        self.rendererView.needsDisplay = true
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
            if let jsonDict = createJSONObjectFromJSONString(jsonString) as? [String:AnyObject]
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
            return NSString(string: NSString(string: filePath).lastPathComponent).stringByDeletingPathExtension
        }
        return movies
    }

    private class func listOfImages() -> [String] {
        let bundle = NSBundle(forClass: self)
        let moviePaths = bundle.pathsForResourcesOfType("jpg", inDirectory: "Pictures")
        
        let examples = moviePaths.map() {
            filePath -> String in return NSString(string: NSString(string: filePath).lastPathComponent).stringByDeletingPathExtension
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
            print("Invalid JSON file: \(fileURL)")
        }
    }
    
    private func stringForCurrentSegment() -> String? {
        return jsonSegmentStrings[commandSegments.selectedSegment]
    }

    private func createDictionary() -> [String:AnyObject] {
        var jsonDict:[String:AnyObject] = [:]

        var currentSegment: JSONSegment? = JSONSegment.firstSegment
        while currentSegment != nil {
            let theSegment = currentSegment!
            jsonDict[theSegment.stringValue] = createJSONObjectFromJSONString(
                                jsonSegmentStrings[theSegment.rawValue]!)
            currentSegment = theSegment.next()
        }
        return jsonDict
    }

    private func updateVariables() -> Void {
        self.miContext.dropVariablesDictionary(self.lastEvaluatedVariables,
            appendNewDictionary: self.variables)
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
            if theSegment == self.lastSelectedSegment {
                jsonTextView.string = jsonSegmentStrings[self.lastSelectedSegment.rawValue]
            }
            currentSegment = theSegment.next()
        }
        for spinner in spinners {
            spinner.view.hidden = true
        }

        // self.exportFileName = jsonDict["exportfilename"] as? String
        if let fileName = jsonDict["exportfilename"] as? String {
            self.exportMediaFilename.stringValue = fileName
        }

        if let varDefs:AnyObject =
            jsonDict[JSONSegment.Variables.stringValue],
            let variableDefs = varDefs as? [AnyObject]
        {
            for (index, variableDefinition) in variableDefs.enumerate() {
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

    // private var exportFileName:String?
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
    private var destination:String = ""
    
    private var variables:[String:AnyObject] {
        get {
            var theDictionary:[String:AnyObject] = [
                MIJSONKeyWidth : rendererView.drawWidth,
                MIJSONKeyHeight : rendererView.drawHeight,
                "movie1path" : movie1Filepath,
                "movie2path" : movie2Filepath
            ]
            for spinner in spinners {
                if !spinner.view.hidden {
                    theDictionary[spinner.variableKey] = spinner.spinnerValue
                }
            }
            
            let fileName = self.exportMediaFilename.stringValue
            let filePath = NSString(string: self.exportFolderLocation).stringByAppendingPathComponent(fileName)
            theDictionary["exportfilepath"] = filePath
            return theDictionary
        }
    }

    private var miContext:MIContext = MIContext()
    
    private var lastEvaluatedVariables:[String:AnyObject]?
}

// MARK: ZukiniDemoController extension managing resources.
extension ZukiniDemoController {
    private func movieNameToPath(name: String) -> String {
        let fileName = NSString(string: name).stringByAppendingPathExtension("mov")!
        let moviePath = NSString(string: "Movies").stringByAppendingPathComponent(fileName)
        let theBundle = NSBundle(forClass: self.dynamicType)
        return NSString(string: theBundle.resourcePath!).stringByAppendingPathComponent(moviePath)
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
        let fileName = NSString(string: name).stringByAppendingPathExtension("jpg")!
        let moviePath = NSString(string: "Images").stringByAppendingPathComponent(fileName)
        let theBundle = NSBundle(forClass: self.dynamicType)
        return NSString(string: theBundle.resourcePath!).stringByAppendingPathExtension(moviePath)!
    }
}

// MARK: ZukiniDemoController. Delegate protocol extensions.
extension ZukiniDemoController: SpinnerDelegate {
    func spinnerValueChanged() {
        self.updateVariables()
        self.rendererView.needsDisplay = true
    }
    
    func spinnersModified() {
        var variablesString:String = ""

        var variablesArray = [[String:AnyObject]]()
        for spinner in spinners {
            if !spinner.view.hidden {
                variablesArray.append(spinner.spinnerDictionary())
            }
        }
        variablesString = makePrettyJSONFromJSONObject(variablesArray)!
        
        jsonSegmentStrings[JSONSegment.Variables.rawValue] = variablesString
        if self.lastSelectedSegment == JSONSegment.Variables {
            self.jsonTextView.string = variablesString
        }
    }
}

extension ZukiniDemoController: NSWindowDelegate {
    func windowDidResize(notification: NSNotification) {
        self.updateVariables()
        // self.rendererView.needsDisplay = true
        if let theWindow = self.window {
            let windowWidth = theWindow.frame.width
            let windowHeight = theWindow.frame.height
            let windowX = theWindow.frame.origin.x
            let windowY = theWindow.frame.origin.y
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(Int(windowWidth),
                forKey: ZukiniDemoController.windowWidthKey)
            defaults.setInteger(Int(windowHeight),
                forKey: ZukiniDemoController.windowHeightKey)
            defaults.setInteger(Int(windowX),
                forKey: ZukiniDemoController.windowXKey)
            defaults.setInteger(Int(windowY),
                forKey: ZukiniDemoController.windowYKey)
        }
    }

    func windowDidMove(notification: NSNotification) {
        if let theWindow = self.window {
            let windowWidth = theWindow.frame.width
            let windowHeight = theWindow.frame.height
            let windowX = theWindow.frame.origin.x
            let windowY = theWindow.frame.origin.y
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(Int(windowWidth),
                forKey: ZukiniDemoController.windowWidthKey)
            defaults.setInteger(Int(windowHeight),
                forKey: ZukiniDemoController.windowHeightKey)
            defaults.setInteger(Int(windowX),
                forKey: ZukiniDemoController.windowXKey)
            defaults.setInteger(Int(windowY),
                forKey: ZukiniDemoController.windowYKey)
        }
    }
    
    func windowDidEnterFullScreen(notification: NSNotification) {
        self.updateVariables()
        if let _ = self.window {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(true, forKey: ZukiniDemoController.windowFullScreenKey)
        }
    }

    func windowDidExitFullScreen(notification: NSNotification) {
        self.updateVariables()
        if let _ = self.window {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(false, forKey: ZukiniDemoController.windowFullScreenKey)
        }
    }
}

extension ZukiniDemoController: NSTextViewDelegate {
    func textDidChange(notification: NSNotification) {
        if let theText = jsonTextView.string {
            jsonSegmentStrings[self.lastSelectedSegment.rawValue] = theText
            if lastSelectedSegment == JSONSegment.DrawInstructions {
                rendererView.drawDictionary =
                    createJSONObjectFromJSONString(theText) as? [String:AnyObject]
                rendererView.needsDisplay = true
            }
        }
    }
}
