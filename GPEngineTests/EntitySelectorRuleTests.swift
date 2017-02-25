//
//  EntitySelectorTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 25/02/17.
//  Copyright © 2017 Luiz Fernando Silva. All rights reserved.
//

import XCTest

class EntitySelectorTests: XCTestCase {
    
    func testRuleAll() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .any
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssert(rule.evaluate(with: entity2))
        XCTAssert(rule.evaluate(with: entity3))
    }
    
    func testRuleNone() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .none
        
        XCTAssertFalse(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
        XCTAssertFalse(rule.evaluate(with: entity3))
    }
    
    func testRuleComponent() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        
        let component = TestComponent()
        
        space.addComponent(component, entity: entity1)
        
        let rule: EntitySelector = .component(TestComponent.self)
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
    }
    
    func testRuleId() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let rule: EntitySelector = .withId(1)
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
    }
    
    func testRuleType() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.type = 1
        entity2.type = 2
        entity3.type = 3
        
        let rule: EntitySelector = .typeFlag(1)
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
        XCTAssert(rule.evaluate(with: entity3))
    }
    
    func testRuleAnd() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity1)
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .and([.component(TestComponent.self), .withId(1)])
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
    }
    
    func testRuleOr() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .or([.component(TestComponent.self), .withId(1)])
        
        XCTAssert(rule.evaluate(with: entity1))
        XCTAssert(rule.evaluate(with: entity2))
        XCTAssertFalse(rule.evaluate(with: entity3))
    }
    
    func testRuleNot() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .not(.or([.component(TestComponent.self), .withId(1)]))
        
        XCTAssertFalse(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
        XCTAssert(rule.evaluate(with: entity3))
    }
    
    func testRuleClosure() {
        let space = Space()
        let entity1 = Entity(space)
        
        let e = expectation(description: "closure called")
        
        let rule: EntitySelector = .closure { entity in
            e.fulfill()
            return true
        }
        
        XCTAssert(rule.evaluate(with: entity1))
        
        waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testAndRuleEmpty() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .and([])
        
        XCTAssertFalse(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
        XCTAssertFalse(rule.evaluate(with: entity3))
    }
    
    func testOrRuleEmpty() {
        let space = Space()
        let entity1 = Entity(space)
        let entity2 = Entity(space)
        let entity3 = Entity(space)
        
        entity1.id = 1
        entity2.id = 2
        
        let component = TestComponent()
        space.addComponent(component, entity: entity2)
        
        let rule: EntitySelector = .or([])
        
        XCTAssertFalse(rule.evaluate(with: entity1))
        XCTAssertFalse(rule.evaluate(with: entity2))
        XCTAssertFalse(rule.evaluate(with: entity3))
    }
    
    func testAndShortcut() {
        let space = Space()
        let entity1 = Entity(space)
        
        let rule: EntitySelector = .and([.none, .closure { entity in
            XCTFail("Should have shortcircuited")
            return true
        }])
        
        XCTAssertFalse(rule.evaluate(with: entity1))
    }
    
    func testOrShortcut() {
        let space = Space()
        let entity1 = Entity(space)
        
        let rule: EntitySelector = .or([.any, .closure { entity in
            XCTFail("Should have shortcircuited")
            return true
        }])
        
        XCTAssert(rule.evaluate(with: entity1))
    }
}
