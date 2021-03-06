//  MovingImages_DemoTests.swift
//  MovingImages DemoTests
//
//  Copyright (c) 2015 Zukini Ltd.

import Cocoa
import XCTest

class MovingImages_DemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation
        // of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation
        // of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleRenderViewVariables() {
        // This is an example of a functional test case.
        let simpleRendererView = SimpleRendererView(frame: NSRect(x: 200, y: 200,
            width: 800, height: 800))
        
        if let _ = simpleRendererView.variables {
            XCTAssert(false,
                "Variables dictionary not set, should have Optional.None")
        }
        else {
            XCTAssert(true, "Variables dictionary undefined")
        }
        
        let variables = [
            "arm1rotation" : 0.2 * M_PI,
            "arm2rotation" : 0.3 * M_PI
        ]
        simpleRendererView.variables = variables
        
        if let _ = simpleRendererView.variables {
            XCTAssert(true, "Variables dictionary should be defined")
        }
        else {
            XCTAssert(false,
                "Variables dictionary should be defined")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
