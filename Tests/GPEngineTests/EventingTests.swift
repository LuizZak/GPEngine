//
//  EventingTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import XCTest
@testable import GPEngine

class EventingTests: XCTestCase {
    var disp = GameEventDispatcher()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        disp = GameEventDispatcher()
    }

    func testMultiEventAdd() { // TODO: This test may be misconstructed: The test doesn't perform the script it claims in the comments
        // Test multiple event hooking
        //
        // 1. Add one listener to two events
        // -> The event count should be 2!
        // 
        // 2. Remove all listeners on that listener
        // 3. Add the same listener twice on the same event
        // 4. Dispatch that event
        // -> The listener should only be called once!
        
        let receiv = EventReceiverTestClass()
        
        let key1 = disp.addListener(receiv, forEventType: CustomEvent.self)
        _ = disp.addListener(receiv, forEventType: OtherCustomEvent.self)
        
        XCTAssertEqual(disp.eventCount, 2)
        
        disp.removeListener(forKey: key1)
        disp.dispatchEvent(OtherCustomEvent())
        
        XCTAssertEqual(receiv.hitCount, 1)
    }
    
    func testEventRemove() {
        // Test the removeListener(forKey:)
        //
        // 1. Add one listener to two event types
        // 2. Use the removeListener(forKey:) with that listener
        // -> The event count should be 1!
        //
        // 3. Remove the other missing event
        // -> The event count should be 0!
        //
        // 4. Add two listeners to an event type
        // -> The event count should be 1!
        //
        // 5. Use the removeListener() with one of the listeners
        // -> The event count should still be 1!
        
        let receiv1 = EventReceiverTestClass()
        let receiv2 = EventReceiverTestClass()
        
        var key1 = disp.addListener(receiv1, forEventType: CustomEvent.self)
        var key2 = disp.addListener(receiv1, forEventType: OtherCustomEvent.self)
        
        disp.removeListener(forKey: key1)
        
        XCTAssertEqual(disp.eventCount, 1)
        
        disp.removeListener(forKey: key2)
        
        XCTAssertEqual(disp.eventCount, 0)
        
        key1 = disp.addListener(receiv1, forEventType: CustomEvent.self)
        key2 = disp.addListener(receiv2, forEventType: OtherCustomEvent.self)
        
        XCTAssert(disp.eventCount == 2)
        
        disp.removeListener(receiv1)
        
        XCTAssertEqual(disp.eventCount, 1)
    }
    
    func testEventRemoveAll() {
        // Test the removeListener(_:)
        // 
        // 1. Add one listener to two different event types
        // 2. Use the removeListener() with that listener
        // -> The event count should be 0!
        
        let receiv = EventReceiverTestClass()
        _ = disp.addListener(receiv, forEventType: CustomEvent.self)
        _ = disp.addListener(receiv, forEventType: OtherCustomEvent.self)
        
        disp.removeListener(receiv)
        
        XCTAssertEqual(disp.eventCount, 0, "The event count should reset to 0 once the receiver was removed as a sole listener to multiple events")
    }
    
    func testEventDispatch() {
        // Test the basic event dispatching
        //
        // 1. Add one listener to an event type
        // 2. Dispatch that event
        // -> The listener should be called!
        
        let receiv = EventReceiverTestClass()
        _ = disp.addListener(receiv, forEventType: CustomEvent.self)
        
        disp.dispatchEvent(CustomEvent())
        
        XCTAssert(receiv.received, "The entity should have received the event")
    }
    
    func testMultiListenersEventDispatch() {
        // Test multiple listeners to same event dispatching
        //
        // 1. Add two listeners to an event type
        // 2. Dispatch that event
        // -> Both listeners should be called!
        
        let receiv1 = EventReceiverTestClass()
        let receiv2 = EventReceiverTestClass()
        _ = disp.addListener(receiv1, forEventType: CustomEvent.self)
        _ = disp.addListener(receiv2, forEventType: CustomEvent.self)
        
        disp.dispatchEvent(CustomEvent())
        
        XCTAssert(receiv1.received && receiv2.received, "All listeners must receive events dispatched from the dispatcher")
    }
    
    func testRemoveAllListeners() {
        // Test the removeAllEvents() method on the dispatcher
        // 
        // 1. Add two listeners to two distict events
        // 2. Use the removeAllEvents() to clear the events
        // -> The event count should be 0!
        
        let receiv1 = EventReceiverTestClass()
        let receiv2 = EventReceiverTestClass()
        _ = disp.addListener(receiv1, forEventType: CustomEvent.self)
        _ = disp.addListener(receiv2, forEventType: OtherCustomEvent.self)
        
        disp.removeAllListeners()
        
        XCTAssertEqual(disp.eventCount, 0, "The event dispatcher must be clear after a removeAllEvents() call")
    }
    
    func testRemoveListenerForKeyIgnoresInvalidatedKeys() {
        let receiv = EventReceiverTestClass()
        let key = disp.addListener(receiv, forEventType: CustomEvent.self)
        key.valid.value = false
        
        disp.removeListener(forKey: key)
        
        XCTAssertEqual(disp.eventCount, 1)
    }
    
    func testKeyInvalidateOnRemoveAllEvents() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeAllEvents
        
        let receiver = EventReceiverTestClass()
        let key = disp.addListener(receiver, forEventType: CustomEvent.self)
        
        disp.removeAllListeners()
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnRemoveByKey() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeListener(forKey:)
        
        let receiver = EventReceiverTestClass()
        let key = disp.addListener(receiver, forEventType: CustomEvent.self)
        
        disp.removeListener(forKey: key)
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnRemoveListener() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeListener(_:)
        
        let receiver = EventReceiverTestClass()
        let key = disp.addListener(receiver, forEventType: CustomEvent.self)
        
        disp.removeListener(receiver)
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnDispatcherDealloc() {
        // Tests that an event listener key invalidates when the event
        // dispatcher deinits
        
        var key: EventListenerKey!
        let receiver = EventReceiverTestClass()
        
        autoreleasepool {
            let disp = GameEventDispatcher()
            
            key = disp.addListener(receiver, forEventType: CustomEvent.self)
            
            _ = disp.addListener(receiver, forEventType: CustomEvent.self)
        } // disp is invalidated here!
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testClosureEventListener() {
        // Test the ClosureEventListener utlity struct, which filters event
        // types using a generic type
        
        let exp = expectation(description: "")
        let receiv1 = ClosureEventListener<CustomEvent> { _ in
            exp.fulfill()
        }
        let receiv2 = ClosureEventListener<OtherCustomEvent> { _ in
            XCTFail("Should not have fired")
        }
        _ = disp.addListener(receiv1, forEventType: CustomEvent.self)
        _ = disp.addListener(receiv2, forEventType: OtherCustomEvent.self)
        
        disp.dispatchEvent(CustomEvent())
        
        waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testGlobalEventNotifier() {
        
        let receiver = EventReceiverTestClass()
        _ = disp.addListenerForAllEvents(receiver)
        
        disp.dispatchEvent(CustomEvent())
        disp.dispatchEvent(OtherCustomEvent())
        
        XCTAssertEqual(receiver.hitCount, 2)
        
        // Make sure we're able to unsubscribe the event listener normally
        disp.removeListener(receiver)
        
        disp.dispatchEvent(CustomEvent())
        
        XCTAssertEqual(receiver.hitCount, 2)
    }
    
    func testClosureGlobalEventListener() {
        
        var count = 0
        let exp = expectation(description: "")
        
        let receiver = ClosureAnyEventListener { _ in
            count += 1
            
            if count == 2 {
                exp.fulfill()
            }
        }
        
        let key = disp.addListenerForAllEvents(receiver)
        
        disp.dispatchEvent(CustomEvent())
        disp.dispatchEvent(OtherCustomEvent())
        
        waitForExpectations(timeout: 0, handler: nil)
        
        // Make sure we're able to unsubscribe the event listener normally
        disp.removeListener(forKey: key)
        
        disp.dispatchEvent(CustomEvent())
        
        XCTAssertEqual(count, 2)
    }
    
    func testRemoveEventIgnoresEventKeysFromOtherDispatchers() {
        let disp1 = GameEventDispatcher()
        let disp2 = GameEventDispatcher()
        let receiv = EventReceiverTestClass()
        _ = disp1.addListener(receiv, forEventType: CustomEvent.self)
        let key = disp2.addListener(receiv, forEventType: CustomEvent.self)
        
        disp1.removeListener(forKey: key)
        
        XCTAssertTrue(key.valid.value)
    }
}

// Test class used to capture event receiving
class EventReceiverTestClass: Entity, GameEventListener {
    var received = false
    var hitCount = 0
    
    func receiveEvent(_ event: GameEvent) {
        received = true
        hitCount += 1
    }
}

// Custom event used to test different event types
class CustomEvent: GameEvent {
    
}

// Custom event used to test different event types
class OtherCustomEvent: GameEvent {
    
}
