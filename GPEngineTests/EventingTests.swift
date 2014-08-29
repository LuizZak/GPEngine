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
        disp = GPEventDispatcher();
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
        
        disp.removeAllEventsForListener(receiv);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        disp.addEventListener(receiv, eventType: GPEvent.self);
        
        disp.dispatchEvent(GPEvent());
        
        XCTAssert(receiv.hitCount == 1, "Listeners must only be called once per dispatch to an event they are listening to, no mare how many times they are added as listeners to that event")
    }
    
    func testEventRemove()
    {
        var skNode = SKNode();
        var receiv1 = EventReceiverTestClass(skNode);
        var receiv2 = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv1, eventType: GPEvent.self);
        
        disp.removeAllEventsForListener(receiv1);
        
        XCTAssert(disp.eventCount == 0, "The event count should reset to 0 once the receiver was removed as a sole listener to a single event")
        
        disp.addEventListener(receiv1, eventType: GPEvent.self);
        disp.addEventListener(receiv2, eventType: GPEvent.self);
        
        XCTAssert(disp.eventCount == 1, "There should be only one event count per event type currently on the event dispatcher, ignoring multiple listeners from the same event")
        
        disp.removeAllEventsForListener(receiv1);
        
        XCTAssert(disp.eventCount == 1, "The event count should only go down once an event hits 0 listeners")
    }
    
    func testEventRemoveAll()
    {
        var skNode = SKNode();
        var receiv = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv, eventType: GPEvent.self);
        disp.addEventListener(receiv, eventType: CustomEvent.self);
        
        disp.removeAllEventsForListener(receiv);
        
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
    
    func testRemoveAllListeners()
    {
        var skNode = SKNode();
        var receiv1 = EventReceiverTestClass(skNode);
        var receiv2 = EventReceiverTestClass(skNode);
        
        disp.addEventListener(receiv1, eventType: GPEvent.self);
        disp.addEventListener(receiv2, eventType: GPEvent.self);
        
        disp.removeAllEvents();
        
        XCTAssert(disp.eventCount == 0, "The event dispatcher must be clear after a removeAllEvents() call");
    }
}

class EventReceiverTestClass: GPEntity, GPEventListener
{
    var received = false;
    var hitCount = 0;
    
    func receiveEvent(event: GPEvent)
    {
        received = true;
        hitCount++;
    }
}

class CustomEvent: GPEvent
{
    
}