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
    return .None
}

class SimpleRendererWindowController: NSWindowController, NSTextViewDelegate {

    @IBOutlet var drawElementJSON: NSTextView!
    
    @IBOutlet var simpleRenderView: SimpleRendererView!

    override func windowDidLoad() {
        super.windowDidLoad()
        drawElementJSON.delegate = self
        drawElementJSON.automaticQuoteSubstitutionEnabled = false
    }
    
    func textDidChange(notification: NSNotification) {
        if let jsonText = drawElementJSON.string,
            let theDict = createDictionaryFromJSONString(jsonText) {
            simpleRenderView.drawDictionary = theDict
            simpleRenderView.needsDisplay = true
        }
    }
}
