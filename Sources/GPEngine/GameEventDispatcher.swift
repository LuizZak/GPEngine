//
//  GameEventDispatcher.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Delegation for a game event dispatcher
protocol GameEventDispatcherDelegate: class {
    /// Called when an event dispatcher is about to dispatch an event.
    /// This delegate method is called regardless if there are any listeners
    /// to the event passed.
    func gameEventDispatcher(_ eventDispatcher: GameEventDispatcher, willDispatch event: GameEvent)
}

extension GameEventDispatcherDelegate {
    func gameEventDispatcher(_ eventDispatcher: GameEventDispatcher, willDispatch event: GameEvent) {
        
    }
}

fileprivate let __globalEventsKey = "__globalEventsListener"

/// A class that is responsible for handling dispatching of events and their
/// associated receivers
open class GameEventDispatcher: Equatable {
    
    weak var delegate: GameEventDispatcherDelegate?
    
    /// Represents the dictionary of event receivers listening specific events
    fileprivate var events: [String: [(listener: GameEventListener, key: EventListenerKey)]] = [String: [(GameEventListener, EventListenerKey)]]()
    
    /// Gets the number of events currently registered on this GameEventDispatcher
    open var eventCount: Int { return events.count }
    
    public init() {
        
    }
    
    deinit {
        removeAllEvents()
    }
    
    /// Adds an event listener that will receive all events dispatched.
    open func addListenerForAllEvents(_ listener: GameEventListener) -> EventListenerKey {
        return addListener(listener, forEventNamed: __globalEventsKey)
    }
    
    /// Makes a given event listener listen for a specific type of event
    /// dispatched on this event dispatcher.
    ///
    /// Note: If listener === self, this will result in a trap.
    open func addListener(_ listener: GameEventListener, forEventType eventType: GameEvent.Type) -> EventListenerKey {
        let eventId = eventType.eventIdentifier
        
        return addListener(listener, forEventNamed: eventId)
    }
    
    fileprivate func addListener(_ listener: GameEventListener, forEventNamed eventId: String) -> EventListenerKey {
        if listener as? GameEventDispatcher === self {
            fatalError("Cannot make dispatcher listen to its own events")
        }
        
        let key: EventListenerKey
        
        // Try to find the key bonded to the event
        if var list = self.events[eventId] {
            key = uniqueKey(forEvent: eventId, forList: list)
            
            list.append((listener, key))
            self.events[eventId] = list
        }
            // If none exist, start a new one
        else {
            key = uniqueKey(forEvent: eventId, forList: [])
            
            self.events[eventId] = [(listener, key)]
        }
        
        return key
    }
    
    /// Removes an event listener with a given key from this event dispatcher
    open func removeListener(forKey key: EventListenerKey) {
        if(!key.valid.value) {
            return
        }
        
        guard var list = events[key.eventIdentifier] else {
            return
        }
        guard let index = list.index(where: { $0.key == key }) else {
            return
        }
        
        list.remove(at: index)
        events[key.eventIdentifier] = list
        key.valid.value = false
        
        if(list.count == 0) {
            self.events.removeValue(forKey: key.eventIdentifier)
        }
    }
    
    /// Removes the given event listener from listening to a specific type of
    /// events
    open func removeListener<T: GameEventListener>(_ listener: T, forEventType eventType: GameEvent.Type) where T: Equatable {
        let eventId = eventType.eventIdentifier
        
        self.internalRemoveEventListener(listener, eventId)
    }
    
    /// Removes a given event listener from all events it is currently 
    /// listening to
    open func removeListener<T: GameEventListener>(_ listener: T) where T: Equatable {
        var i: Int = 0
        while(i < self.events.keys.count) {
            let c: Int = self.events.count
            
            self.internalRemoveEventListener(listener, Array(self.events.keys)[i])
            
            if(c == self.events.count) {
                i += 1
            }
        }
    }
    
    /// Removes all the events currently registered on this event dispatcher
    open func removeAllEvents() {
        // Invalidate all keys
        for (_, list) in events {
            for (_, key) in list {
                key.valid.value = false
            }
        }
        
        // Clear the event list
        events.removeAll(keepingCapacity: false)
    }
    
    fileprivate func uniqueKey(forEvent event: String, forList keys: [(GameEventListener, EventListenerKey)]) -> EventListenerKey {
        let maxKey = keys.map { $1.key }.max() ?? 0
        
        return EventListenerKey(valid: true, eventIdentifier: event, key: maxKey + 1)
    }
    
    // Internal method that removes an event listener bounded to a given event
    // identifier
    fileprivate func internalRemoveEventListener<T: GameEventListener>(_ listener: T, _ eventIdentifier: String) where T: Equatable {
        // Try to find the key bonded to the event
        guard var list = self.events[eventIdentifier] else {
            return
        }
        
        guard let index = list.index(where: { l, key in l as? T == listener }) else {
            return
        }
        
        list[index].key.valid.value = false
        list.remove(at: index)
        
        self.events[eventIdentifier] = list
        
        if(list.count == 0) {
            self.events.removeValue(forKey: eventIdentifier)
        }
    }
    
    /// Dispatches the given event in this event dispatcher
    open func dispatchEvent(_ event: GameEvent) {
        // Fire delegate
        delegate?.gameEventDispatcher(self, willDispatch: event)
        
        // Find the lsit of listeners
        let eventId = type(of: event).eventIdentifier
        
        dispatchEvent(event, forKeys: eventId)
        
        // Fire for global listeners, as well
        dispatchEvent(event, forKeys: __globalEventsKey)
    }
    
    private func dispatchEvent(_ event: GameEvent, forKeys key: String) {
        guard let list = self.events[key] else {
            return
        }
        
        for (obj, _) in list {
            obj.receiveEvent(event)
        }
    }
    
    /// Performs a reference-equality check between two GameEventDispatcher instances.
    /// Parameter are equal if they reference the same object.
    public static func ==(lhs: GameEventDispatcher, rhs: GameEventDispatcher) -> Bool {
        return lhs === rhs
    }
}

/// Event listener extension for game dispatcher
/// This allows a game event dispatcher to be used as a broadcaster of events
///
/// Note: Trying to add an event dispatcher as its own listener results in a trap.
/// Also, take care to not create event dispatcher cycles, as these will result
/// in infinite loops.
extension GameEventDispatcher: GameEventListener {
    
    /// Forwards the event to all listeners
    public func receiveEvent(_ event: GameEvent) {
        dispatchEvent(event)
    }
}

/// An event listener unique key, used to identify registration to event
/// dispatchers, and later remove them
public struct EventListenerKey: Equatable {
    
    /// Simple wrapper so we maintain EventListenerKey as a value-type, while
    /// also making invalidations of one event listener key be shared across all
    /// other copies of the same key.
    final internal class InnerValid: ExpressibleByBooleanLiteral {
        var value: Bool
        init(booleanLiteral value: Bool) {
            self.value = value
        }
    }
    
    /// Whether this listener key acually points to an event listener.
    /// In case it doesn't, it won't affect dispatches after multiple calls
    /// to removeListener(forKey:)
    internal var valid: InnerValid = true
    
    var eventIdentifier: String
    
    var key: Int
    
    public static func ==(lhs: EventListenerKey, rhs: EventListenerKey) -> Bool {
        return lhs.valid.value == rhs.valid.value && lhs.key == rhs.key
    }
}