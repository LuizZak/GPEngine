//
//  EntityTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import XCTest

import SpriteKit
import GPEngine

class EntityTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testComponentAdd() {
        let space = Space()
        let entity = Entity(space)
        let comp = TestComponent()
        
        space.addComponent(comp, entity: entity)
        
        // Test component count after inclusion being < 1
        XCTAssert(entity.getComponents(ofType: TestComponent.self).count == 1, "The components must be added to the entity after an addComponent() call")
    }
    
    func testComponentRemove() {
        let space = Space()
        let entity = Entity(space)
        let comp = TestComponent()
        
        space.addComponent(comp, entity: entity)
        space.removeComponent(type: TestComponent.self, from: entity)
        
        // Test component count after removal being > 0
        XCTAssert(entity.getComponents(ofType: TestComponent.self).count == 0, "Components must be removed after a removeComponent() call")
    }
    
    func testComponentGetType() {
        let space = Space()
        let entity = Entity(space)
        let comp1 = TestComponent()
        let comp2 = OtherTestComponent()
        
        space.addComponent(comp1, entity: entity)
        space.addComponent(comp2, entity: entity)
        
        // Test component get
        XCTAssert(entity.getComponents(ofType: TestComponent.self).count == 1, "Calls to getComponents(ofType: ) must return a component with that type, or derived from that type only")
        
        // Test complete component get
        XCTAssert(entity.getAllComponents().count == 2, "Calls to getComponents(ofType: ) with a base Component class must return all components registered")
    }
}

class TestComponent: Component {
    var point: CGPoint = CGPoint.zero
}

class OtherTestComponent: Component {
    var point: CGPoint = CGPoint.zero
}
