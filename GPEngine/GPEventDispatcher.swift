//
//  GPEventDispatcher.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// A class that is responsible for handling dispatching of events and their associated receivers
class GPEventDispatcher: NSObject
{
    // Represents the dictionary of event receivers listening specific events
    private var events: [String: [GPEventListener]] = [String: [GPEventListener]]();
    
    // Gets the number of events currently registered on this GPEventDispatcher
    var eventCount: Int { get { return events.count; } }
    
    // Makes a given event listener listen for a specific type of event dispatched on this event dispatcher
    func addEventListener<T: GPEventListener where T: Equatable>(listener: T, eventType: AnyClass)
    {
        var hashEventType = NSStringFromClass(eventType);
        
        // Try to find the key bonded to the event
        if var list = self.events[hashEventType]
        {
            if(!list.contains(listener))
            {
                list += listener;
                self.events[hashEventType] = list;
            }
        }
        // If none exist, start a new one
        else
        {
            self.events[hashEventType] = [listener];
        }
    }
    
    // Removes the given event listener from listening to a specific type of events
    func removeEventListener<T: GPEventListener where T: Equatable>(listener: T, eventType: AnyClass)
    {
        var hashEventType = NSStringFromClass(eventType);
        
        self.internalRemoveEventListener(listener, hashEventType);
    }
    
    // Removes a given event listener from all events it is currently listening to
    func removeAllEventsForListener<T: GPEventListener where T: Equatable>(listener: T)
    {
        var i: Int = 0;
        while(i < self.events.keys.array.count)
        {
            var c:Int = self.events.count;
            
            self.internalRemoveEventListener(listener, self.events.keys.array[i]);
            
            if(c == self.events.count)
            {
                i++;
            }
        }
    }
    
    // Removes all the events currently registered on this event dispatcher
    func removeAllEvents()
    {
        // Clear the event list
        self.events.removeAll(keepCapacity: false)
    }
    
    // Internal method that removes an event listener bonded to a given event type hash
    private func internalRemoveEventListener<T: GPEventListener where T: Equatable>(listener: T, _ hashEventType: String)
    {
        // Try to find the key bonded to the event
        if var list = self.events[hashEventType]
        {
            list.remove(listener);
            
            if(list.count == 0)
            {
                self.events.removeValueForKey(hashEventType);
            }
        }
    }
    
    // Dispatches the given event in this event dispatcher
    func dispatchEvent(event: GPEvent)
    {
        // Find the lsit of listeners
        var hashEventType = NSStringFromClass(event.classForCoder);
        
        if let list = self.events[hashEventType]
        {
            for obj in list
            {
                obj.receiveEvent(event);
            }
        }
    }
}