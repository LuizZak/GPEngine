//
//  EntityTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import XCTest
@testable import GPEngine

class EntityTests: XCTestCase {
    func testComponentAdd() {
        let space = Space()
        let entity = Entity(space)
        let comp = TestComponent()
        
        space.addComponent(comp, to: entity)
        
        // Test component count after inclusion being < 1
        XCTAssertEqual(entity.components(ofType: TestComponent.self).count, 1, "The components must be added to the entity after an addComponent() call")
    }
    
    func testComponentRemove() {
        let space = Space()
        let entity = Entity(space)
        let comp = TestComponent()
        
        space.addComponent(comp, to: entity)
        space.removeComponent(type: TestComponent.self, from: entity)
        
        // Test component count after removal being > 0
        XCTAssertEqual(entity.components(ofType: TestComponent.self).count, 0, "Components must be removed after a removeComponent() call")
    }
    
    func testComponentGetType() {
        let space = Space()
        let entity = Entity(space)
        let comp1 = TestComponent()
        let comp2 = OtherTestComponent()
        
        space.addComponent(comp1, to: entity)
        space.addComponent(comp2, to: entity)
        
        // Test component get
        XCTAssertEqual(entity.components(ofType: TestComponent.self).count, 1, "Calls to components(ofType: ) must return a component with that type, or derived from that type only")
        
        // Test complete component get
        XCTAssertEqual(entity.getAllComponents().count, 2, "Calls to components(ofType: ) with a base Component class must return all components registered")
        
        space.removeComponent(type: TestComponent.self, from: entity)
        
        XCTAssertNil(entity.component(ofType: TestComponent.self))
        XCTAssertNotNil(entity.component(ofType: OtherTestComponent.self))
    }
    
    func testWithComponentsOfType() {
        let comp1 = TestComponent()
        let comp2 = OtherTestComponent()
        let comp3 = OtherTestComponent()
        let entity = Entity(components: [comp1, comp2, comp3])
        
        var fireCount = 0
        entity.withComponents(ofType: TestComponent.self) { _ in
            fireCount += 1
        }
        
        XCTAssertEqual(fireCount, 1)
        
        fireCount = 0
        entity.withComponents(ofType: OtherTestComponent.self) { _ in
            fireCount += 1
        }
        
        XCTAssertEqual(fireCount, 2)
    }
    
    func testWithTwoComponentsOfType() {
        let comp1 = TestComponent()
        let comp2 = OtherTestComponent()
        let entity = Entity(components: [comp1, comp2])
        
        var fireCount = 0
        entity.withComponents(ofTypes: TestComponent.self, OtherTestComponent.self) { _, _ in
            fireCount += 1
        }
        
        // Test type-inferred version
        entity.withComponents { (_: TestComponent, _: OtherTestComponent) in
            fireCount += 1
        }
        
        XCTAssertEqual(fireCount, 2)
    }
    
    func testWithThreeComponentsOfType() {
        let comp1 = TestComponent()
        let comp2 = OtherTestComponent()
        let comp3 = ThirdTestComponent()
        let entity = Entity(components: [comp1, comp2, comp3])
        
        var fireCount = 0
        entity.withComponents(ofTypes: TestComponent.self, OtherTestComponent.self, ThirdTestComponent.self) { _, _, _ in
            fireCount += 1
        }
        
        // Test type-inferred version
        entity.withComponents { (_: TestComponent, _: OtherTestComponent, _: ThirdTestComponent) in
            fireCount += 1
        }
        
        XCTAssertEqual(fireCount, 2)
    }
}

class TestComponent: Component {
    
}

class OtherTestComponent: Component {
    
}

class ThirdTestComponent: Component {
    
}
