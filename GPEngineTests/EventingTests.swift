//
//  EventingTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import XCTest

import SpriteKit
import GPEngine

class EventingTests: XCTestCase
{
    var disp = GPEventDispatcher();
    
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
    
    func testMultiEventAdd()
    {
        var skNode = SKNode();
        var receiv = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        disp.addEventListener(receiv, eventType: CustomEvent.self);
        
        XCTAssert(disp.eventCount == 2, "The event count should match the two events added to the receiver")
    }
    
    func testEventRemove()
    {
        var skNode = SKNode();
        var receiv = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        
        disp.removeAllEvents(receiv);
        
        XCTAssert(disp.eventCount == 0, "The event count should reset to 0 once the receiver was removed as a sole listener to a single event")
    }
    
    func testEventRemoveAll()
    {
        var skNode = SKNode();
        var receiv = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        disp.addEventListener(receiv, eventType: CustomEvent.self);
        
        disp.removeAllEvents(receiv);
        
        XCTAssert(disp.eventCount == 0, "The event count should reset to 0 once the receiver was removed as a sole listener to multiple events")
    }
    
    func testEventDispatch()
    {
        var skNode = SKNode();
        var receiv = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        disp.dispatchEvent(GPEvent());
        
        XCTAssert(receiv.received, "The entity should have received the event")
    }
    
    func testMultiListenersEventDispatch()
    {
        var skNode = SKNode();
        var receiv1 = EventReceiverTestClass(skNode);
        var receiv2 = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv1, eventType: GPEvent.self);
        disp.addEventListener(receiv2, eventType: GPEvent.self);
        
        disp.dispatchEvent(GPEvent());
        
        XCTAssert(receiv1.received && receiv2.received, "All listeners must receive events dispatched from the dispatcher")
    }
}

class EventReceiverTestClass: GPEntity, GPEventListener, Equatable
{
    var received = false;
    
    func receiveEvent(event: GPEvent)
    {
        received = true;
    }
}

class CustomEvent: GPEvent
{
    
}

func ==(lhs: EventReceiverTestClass, rhs: EventReceiverTestClass) -> Bool
{
    return lhs.isEqual(rhs);
}