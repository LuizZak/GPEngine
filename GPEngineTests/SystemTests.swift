//
//  SystemTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import XCTest

import SpriteKit
import GPEngine

class SystemTests: XCTestCase
{
    var view: SKView?;
    var scene: GPGameScene?;
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        view = SKView();
        scene = GPGameScene();
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        
        view = nil;
    }

    func testAddSystem()
    {
        var system = CustomSystem();
        
        scene?.addSystem(system);
        
        // Test system add
        XCTAssert(scene?.getSystemWithType(GPSystem) != nil, "Systems must be added after a call to GPGameScene.addSystem()")
    }
}

class CustomSystem: GPSystem
{
    
}