//  ZukiniUtilities.swift
//  MovingImages Demo
//
//  Copyright (c) 2015 Kevin Meaney.

import Foundation

extension Double {
    func stringWithMaxnumberOfFractionAndIntDigits(maxnumber: Int) -> String {
        let numIntDigits:Int
        if self > 0.9999 {
            numIntDigits = Int(log10(self))
        }
        else if self < -0.9999 {
            numIntDigits = Int(log10(-self))
        }
        else {
            numIntDigits = 0
        }
        let numDigits:Int = maxnumber
        let numFractionDigits:Int
        if numIntDigits > numDigits {
            numFractionDigits = 0
        }
        else {
            numFractionDigits = numDigits - numIntDigits - 1
        }
        let format = String(format: "%%.%if", numFractionDigits)
        return String(format: format, self)
    }
}

extension Float {
    func stringWithMaxnumberOfFractionAndIntDigits(maxnumber: Int) -> String {
        return Double(self).stringWithMaxnumberOfFractionAndIntDigits(maxnumber)
    }
}

func listOfExamples(#prefix: String) -> [String] {
    // Find list of JSON file in the first instance in the application
    // bundle. Might change this to application support as well
    // at some point which would take precedence.
    let bundle = NSBundle.mainBundle()
    let allJSONPaths = bundle.pathsForResourcesOfType("json",
        inDirectory: Optional.None)
    let simpleRendererJSONPaths = allJSONPaths.filter() { filePath -> Bool in
        let fileName = filePath.lastPathComponent
        if fileName.hasPrefix(prefix) {
            return true
        }
        return false
    }
    
    let examples = simpleRendererJSONPaths.map() { filePath -> String in
        let fileName = filePath.lastPathComponent
        let subString = fileName.substringFromIndex(prefix.endIndex)
        return subString
    }
    return examples
}

func exampleNameToFilePath(exampleName: String, #prefix: String) -> String {
    let fileName = prefix + exampleName
    let resourcesURL = NSBundle.mainBundle().resourceURL!
    let resourceURL = resourcesURL.URLByAppendingPathComponent(fileName)
    return resourceURL.path!
}

func readJSONFromFile(filePath: String) -> [String:AnyObject]? {
    if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
        if let inStream = NSInputStream(fileAtPath: filePath) {
            inStream.open()
            let container:AnyObject? = NSJSONSerialization.JSONObjectWithStream(
                inStream,
                options: NSJSONReadingOptions.allZeros,
                error: nil)
            if let container:AnyObject = container,
                let dictionary = container as? [String:AnyObject] {
                    return dictionary
            }
            else {
                println("Failed to create a dictionary from file \(filePath)")
            }
        }
        else {
            println("Could not read from file \(filePath)")
        }
    }
    else {
        println("File does not exists: \(filePath)")
    }
    return Optional.None
}

func createDictionaryFromJSONString(jsonString: String) -> [String:AnyObject]? {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding),
        let theDict = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.allZeros,
            error:nil) as? [String:AnyObject] {
                return theDict
    }
    return Optional.None
}

func writeJSONToFile(jsonObject: [String:AnyObject], #filePath: String) -> Void {
    if NSJSONSerialization.isValidJSONObject(jsonObject) {
        if let outputStream = NSOutputStream(toFileAtPath: filePath, append: false) {
            outputStream.open()
            NSJSONSerialization.writeJSONObject(jsonObject, toStream: outputStream,
                options: NSJSONWritingOptions.PrettyPrinted, error:nil)
            outputStream.close()
        }
    }
}

func makePrettyJSONFromDictionary(dictionary: [String:AnyObject]) -> String? {
    if !NSJSONSerialization.isValidJSONObject(dictionary) {
        println("Dictionary is not a valid JSON object")
        return Optional.None
    }
    
    let data = NSJSONSerialization.dataWithJSONObject(dictionary,
        options: NSJSONWritingOptions.PrettyPrinted,
        error: nil)
    
    if let data = data,
        let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) {
            return String(jsonString)
    }
    println("Could not convert dictionary to a json string")
    return Optional.None
}

func createCGImage(name: String, #fileExtension: String) -> CGImage? {
    let bundle = NSBundle.mainBundle()
    if let url = bundle.URLForResource(name, withExtension: fileExtension) {
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            if let imageSource = CGImageSourceCreateWithURL(url as CFURLRef, nil) {
                return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
            }
        }
    }
    return Optional.None
}

func createDictionaryFromJSONFile(name: String, inBundle: NSBundle? = Optional.None) -> [String:AnyObject]? {
    let localBundle:NSBundle
    if let bundle = inBundle {
        localBundle = bundle
    }
    else {
        localBundle = NSBundle.mainBundle()
    }

    if let url = localBundle.URLForResource(name, withExtension: "json"),
       let inStream = NSInputStream(URL: url)
    {
        inStream.open()
        if let container:AnyObject? = NSJSONSerialization.JSONObjectWithStream(
            inStream, options:NSJSONReadingOptions.allZeros, error:nil),
            let theContainer = container as? [String : AnyObject]
        {
            return theContainer
        }
        else
        {
            return Optional.None
        }
    }
    return Optional.None
}
