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

class EntityTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testComponentAdd()
    {
        var node = SKNode();
        var entity = GPEntity(node);
        var comp = GPComponent();
        
        entity.addComponent(comp);
        
        // Test component count after inclusion being < 1
        XCTAssert(entity.getComponentsWithType(GPComponent).count == 1, "The components must be added to the entity after an addComponent() call")
    }
    
    func testComponentRemove()
    {
        var node = SKNode();
        var entity = GPEntity(node);
        var comp = GPComponent();
        
        entity.addComponent(comp);
        entity.removeComponent(comp);
        
        // Test component count after removal being > 0
        XCTAssert(entity.getComponentsWithType(GPComponent).count == 0, "Components must be removed after a removeComponent() call")
    }
    
    func testComponentGetType()
    {
        var node = SKNode();
        var entity = GPEntity(node);
        var comp1 = GPComponent();
        var comp2 = TestComponent();
        
        entity.addComponent(comp1);
        entity.addComponent(comp2);
        
        // Test component get
        XCTAssert(entity.getComponentsWithType(TestComponent).count == 1, "Calls to getComponentsWithType() must return a component with that type, or derived from that type only")
        
        // Test complete component get
        XCTAssert(entity.getComponentsWithType(GPComponent).count == 2, "Calls to getComponentsWithType() with a base GPComponent class must return all components registered")
    }
}

class TestComponent: GPComponent
{
    var point: CGPoint = CGPointZero;
}