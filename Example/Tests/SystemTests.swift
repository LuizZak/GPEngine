//
//  SystemTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import XCTest

import GPEngine

class SystemTests: XCTestCase {
    var game: Game = Game()
    
    override func setUp() {
        super.setUp()
        
        game = Game()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddSystem() {
        let system = CustomSystem()
        
        game.addSystem(system)
        
        // Test system add
        XCTAssertEqual(game.systems.count, 1)
        XCTAssertEqual(game.systems.first, system)
        XCTAssert(game.system(ofType: System.self) != nil, "Systems must be added after a call to GameScene.addSystem()")
    }
    
    func testsystemByType() {
        let system1 = CustomSystem()
        let system2 = OtherCustomSystem()
        
        game.addSystem(system1)
        
        // Test system add
        XCTAssert(game.system(ofType: CustomSystem.self) != nil, "Systems must be added after a call to GameScene.addSystem()")
        XCTAssert(game.system(ofType: OtherCustomSystem.self) == nil)
        
        game.addSystem(system2)
        
        XCTAssert(game.system(ofType: OtherCustomSystem.self) != nil, "Systems must be added after a call to GameScene.addSystem()")
    }
    
    func testRemoveSystem() {
        let system = CustomSystem()
        
        game.addSystem(system)
        game.removeSystem(system)
        
        // Test system add
        XCTAssertEqual(game.systems.count, 0)
        XCTAssert(game.system(ofType: System.self) == nil, "Systems must be removed after a call to GameScene.removeSystem()")
    }
}

class CustomSystem: System {
    
}

class OtherCustomSystem: System {
    
}
