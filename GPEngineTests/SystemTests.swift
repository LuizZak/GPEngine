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

class SystemTests: XCTestCase {
    var view: SKView?
    var game: Game = Game()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        view = SKView()
        game = Game()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        
        view = nil
    }

    func testAddSystem() {
        let system = CustomSystem(game: game)
        
        game.addSystem(system)
        
        // Test system add
        XCTAssert(game.getSystemByType(System.self) != nil, "Systems must be added after a call to GameScene.addSystem()")
    }
    
    func testRemoveSystem() {
        let system = CustomSystem(game: game)
        
        game.addSystem(system)
        game.removeSystem(system)
        
        // Test system add
        XCTAssert(game.getSystemByType(System.self) == nil, "Systems must be removed after a call to GameScene.removeSystem()")
    }
}

class CustomSystem: System {
    
}
