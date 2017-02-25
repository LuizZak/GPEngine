//
//  GameEventDispatcher.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// A class that is responsible for handling dispatching of events and their associated receivers
open class GameEventDispatcher {
    
    // Represents the dictionary of event receivers listening specific events
    fileprivate var events: [String: [GameEventListener]] = [String: [GameEventListener]]()
    
    // Gets the number of events currently registered on this GameEventDispatcher
    open var eventCount: Int { return events.count }
    
    // Makes a given event listener listen for a specific type of event dispatched on this event dispatcher
    open func addEventListener<T: GameEventListener>(_ listener: T, eventType: GameEvent.Type) where T: Equatable {
        // TODO: Find a better way to derive a unique key for the event type for the events dictionary
        let hashEventType = eventType.eventIdentifier
        
        // Try to find the key bonded to the event
        if var list = self.events[hashEventType] {
            if(!list.contains { ($0 as? T) == listener }) {
                list.append(listener)
                self.events[hashEventType] = list
            }
        }
        // If none exist, start a new one
        else {
            self.events[hashEventType] = [listener]
        }
    }
    
    // Removes the given event listener from listening to a specific type of events
    open func removeEventListener<T: GameEventListener>(_ listener: T, eventType: GameEvent.Type) where T: Equatable {
        // TODO: Find a better way to derive a unique key for the event type for the events dictionary
        let hashEventType = eventType.eventIdentifier
        
        self.internalRemoveEventListener(listener, hashEventType)
    }
    
    // Removes a given event listener from all events it is currently listening to
    open func removeAllEventsForListener<T: GameEventListener>(_ listener: T) where T: Equatable {
        var i: Int = 0
        while(i < self.events.keys.count) {
            let c:Int = self.events.count
            
            self.internalRemoveEventListener(listener, Array(self.events.keys)[i])
            
            if(c == self.events.count) {
                i += 1
            }
        }
    }
    
    // Removes all the events currently registered on this event dispatcher
    open func removeAllEvents() {
        // Clear the event list
        self.events.removeAll(keepingCapacity: false)
    }
    
    // Internal method that removes an event listener bonded to a given event type hash
    fileprivate func internalRemoveEventListener<T: GameEventListener>(_ listener: T, _ hashEventType: String) where T: Equatable {
        // Try to find the key bonded to the event
        if var list = self.events[hashEventType] {
            list.removeFirst { ($0 as? T) == listener }
            
            self.events[hashEventType] = list
            
            if(list.count == 0) {
                self.events.removeValue(forKey: hashEventType)
            }
        }
    }
    
    // Dispatches the given event in this event dispatcher
    open func dispatchEvent(_ event: GameEvent) {
        // Find the lsit of listeners
        // TODO: Find a better way to derive a unique key for the event type for the events dictionary
        let hashEventType = type(of: event).eventIdentifier
        
        if let list = self.events[hashEventType] {
            for obj in list {
                obj.receiveEvent(event)
            }
        }
    }
}
