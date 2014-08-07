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
    
    func testRemoveSystem()
    {
        var system = CustomSystem();
        
        scene?.addSystem(system)
        scene?.removeSystem(system)
        
        // Test system add
        XCTAssert(scene?.getSystemWithType(GPSystem) == nil, "Systems must be removed after a call to GPGameScene.removeSystem()")
    }
    
    func testAddEntityNotify()
    {
        var system = CustomSystem();
        
        scene?.addSystem(system)
        
        scene?.addEntity(GPEntity(SKNode()));
        
        // Test system add
        XCTAssert(system.receivedAddEntity, "Systems must be notified of entity insertion via the gameSceneDidAddEntity() method")
    }
    
    func testRemoveEntityNotify()
    {
        var system = CustomSystem();
        var entity = GPEntity(SKNode());
        
        scene?.addSystem(system)
        
        scene?.addEntity(entity);
        scene?.removeEntity(entity);
        
        // Test system add
        XCTAssert(system.receivedRemoveEntity, "System must be notified of entity removal via the gameSceneDidRemoveEntity() method")
    }
    
    func testEntityModifyNotify()
    {
        
    }
}

class CustomSystem: GPSystem
{
    var receivedAddEntity = false;
    var receivedRemoveEntity = false;
    
    override func gameSceneDidAddEntity(entity: GPEntity) -> Bool
    {
        receivedAddEntity = true;
        
        return self.testEntityToAdd(entity);
    }
    
    override func gameSceneDidRemoveEntity(entity: GPEntity) -> Bool
    {
        receivedRemoveEntity = true;
        
        return self.testEntityToRemove(entity);
    }
}