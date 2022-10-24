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
    var sut = GameEventDispatcher()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = GameEventDispatcher()
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
        
        let receiver = EventReceiverTestClass()
        
        let key1 = sut.addListener(receiver, forEventType: CustomEvent.self)
        _ = sut.addListener(receiver, forEventType: OtherCustomEvent.self)
        
        XCTAssertEqual(sut.eventCount, 2)
        
        sut.removeListener(forKey: key1)
        sut.dispatchEvent(OtherCustomEvent())
        
        XCTAssertEqual(receiver.hitCount, 1)
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
        
        let receiver1 = EventReceiverTestClass()
        let receiver2 = EventReceiverTestClass()
        
        var key1 = sut.addListener(receiver1, forEventType: CustomEvent.self)
        var key2 = sut.addListener(receiver1, forEventType: OtherCustomEvent.self)
        
        sut.removeListener(forKey: key1)
        
        XCTAssertEqual(sut.eventCount, 1)
        
        sut.removeListener(forKey: key2)
        
        XCTAssertEqual(sut.eventCount, 0)
        
        key1 = sut.addListener(receiver1, forEventType: CustomEvent.self)
        key2 = sut.addListener(receiver2, forEventType: OtherCustomEvent.self)
        
        XCTAssert(sut.eventCount == 2)
        
        sut.removeListener(receiver1)
        
        XCTAssertEqual(sut.eventCount, 1)
    }
    
    func testEventRemoveAll() {
        // Test the removeListener(_:)
        // 
        // 1. Add one listener to two different event types
        // 2. Use the removeListener() with that listener
        // -> The event count should be 0!
        
        let receiver = EventReceiverTestClass()
        _ = sut.addListener(receiver, forEventType: CustomEvent.self)
        _ = sut.addListener(receiver, forEventType: OtherCustomEvent.self)
        
        sut.removeListener(receiver)
        
        XCTAssertEqual(sut.eventCount, 0, "The event count should reset to 0 once the receiver was removed as a sole listener to multiple events")
    }
    
    func testEventDispatch() {
        // Test the basic event dispatching
        //
        // 1. Add one listener to an event type
        // 2. Dispatch that event
        // -> The listener should be called!
        
        let receiver = EventReceiverTestClass()
        _ = sut.addListener(receiver, forEventType: CustomEvent.self)
        
        sut.dispatchEvent(CustomEvent())
        
        XCTAssert(receiver.received, "The entity should have received the event")
    }
    
    func testMultiListenersEventDispatch() {
        // Test multiple listeners to same event dispatching
        //
        // 1. Add two listeners to an event type
        // 2. Dispatch that event
        // -> Both listeners should be called!
        
        let receiver1 = EventReceiverTestClass()
        let receiver2 = EventReceiverTestClass()
        _ = sut.addListener(receiver1, forEventType: CustomEvent.self)
        _ = sut.addListener(receiver2, forEventType: CustomEvent.self)
        
        sut.dispatchEvent(CustomEvent())
        
        XCTAssert(receiver1.received && receiver2.received, "All listeners must receive events dispatched from the dispatcher")
    }
    
    func testRemoveAllListeners() {
        // Test the removeAllEvents() method on the dispatcher
        // 
        // 1. Add two listeners to two distinct events
        // 2. Use the removeAllEvents() to clear the events
        // -> The event count should be 0!
        
        let receiver1 = EventReceiverTestClass()
        let receiver2 = EventReceiverTestClass()
        _ = sut.addListener(receiver1, forEventType: CustomEvent.self)
        _ = sut.addListener(receiver2, forEventType: OtherCustomEvent.self)
        
        sut.removeAllListeners()
        
        XCTAssertEqual(sut.eventCount, 0, "The event dispatcher must be clear after a removeAllEvents() call")
    }
    
    func testRemoveListenerForKeyIgnoresInvalidatedKeys() {
        let receiver = EventReceiverTestClass()
        let key = sut.addListener(receiver, forEventType: CustomEvent.self)
        key.valid.value = false
        
        sut.removeListener(forKey: key)
        
        XCTAssertEqual(sut.eventCount, 1)
    }
    
    func testKeyInvalidateOnRemoveAllEvents() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeAllEvents
        
        let receiver = EventReceiverTestClass()
        let key = sut.addListener(receiver, forEventType: CustomEvent.self)
        
        sut.removeAllListeners()
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnRemoveByKey() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeListener(forKey:)
        
        let receiver = EventReceiverTestClass()
        let key = sut.addListener(receiver, forEventType: CustomEvent.self)
        
        sut.removeListener(forKey: key)
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnRemoveListener() {
        // Tests that an event listener key invalidates when calling
        // dispatcher.removeListener(_:)
        
        let receiver = EventReceiverTestClass()
        let key = sut.addListener(receiver, forEventType: CustomEvent.self)
        
        sut.removeListener(receiver)
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testKeyInvalidateOnDispatcherDealloc() {
        // Tests that an event listener key invalidates when the event
        // dispatcher deinits
        
        var key: EventListenerKey!
        let receiver = EventReceiverTestClass()
        
        autoreleasepool {
            let sut = GameEventDispatcher()
            
            key = sut.addListener(receiver, forEventType: CustomEvent.self)
            
            _ = sut.addListener(receiver, forEventType: CustomEvent.self)
        } // sut is invalidated here!
        
        XCTAssertFalse(key.valid.value)
    }
    
    func testClosureEventListener() {
        // Test the ClosureEventListener utility struct, which filters event
        // types using a generic type
        
        let exp = expectation(description: "")
        let receiver1 = ClosureEventListener<CustomEvent> { _ in
            exp.fulfill()
        }
        let receiver2 = ClosureEventListener<OtherCustomEvent> { _ in
            XCTFail("Should not have fired")
        }
        _ = sut.addListener(receiver1, forEventType: CustomEvent.self)
        _ = sut.addListener(receiver2, forEventType: OtherCustomEvent.self)
        
        sut.dispatchEvent(CustomEvent())
        
        waitForExpectations(timeout: 0, handler: nil)
    }
    
    func testGlobalEventNotifier() {
        
        let receiver = EventReceiverTestClass()
        _ = sut.addListenerForAllEvents(receiver)
        
        sut.dispatchEvent(CustomEvent())
        sut.dispatchEvent(OtherCustomEvent())
        
        XCTAssertEqual(receiver.hitCount, 2)
        
        // Make sure we're able to unsubscribe the event listener normally
        sut.removeListener(receiver)
        
        sut.dispatchEvent(CustomEvent())
        
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
        
        let key = sut.addListenerForAllEvents(receiver)
        
        sut.dispatchEvent(CustomEvent())
        sut.dispatchEvent(OtherCustomEvent())
        
        waitForExpectations(timeout: 0, handler: nil)
        
        // Make sure we're able to unsubscribe the event listener normally
        sut.removeListener(forKey: key)
        
        sut.dispatchEvent(CustomEvent())
        
        XCTAssertEqual(count, 2)
    }
    
    func testRemoveEventIgnoresEventKeysFromOtherDispatchers() {
        let dispatcher1 = GameEventDispatcher()
        let dispatcher2 = GameEventDispatcher()
        let receiver = EventReceiverTestClass()
        _ = dispatcher1.addListener(receiver, forEventType: CustomEvent.self)
        let key = dispatcher2.addListener(receiver, forEventType: CustomEvent.self)
        
        dispatcher1.removeListener(forKey: key)
        
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
