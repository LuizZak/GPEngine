//
//  TouchEvent.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 10/03/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents an event fired whenever an input event happens
open class TouchEvent: GameEvent {
    /// The type for this event
    open fileprivate(set) var eventType: TouchEventType
    
    /// The touches for the event
    open fileprivate(set) var touches: Set<NSObject>
    
    /// The event for the touch
    open fileprivate(set) var event: UIEvent
    
    /// The view that the event was captured on
    open fileprivate(set) var view: UIView?
    
    init(touches: Set<NSObject>, event: UIEvent, eventType: TouchEventType, view: UIView?) {
        self.eventType = eventType
        self.touches = touches
        self.event = event
        self.view = view
    }
}

/// The type for an input event
public enum TouchEventType {
    /// Input fired whenever a touch event begins
    case touchesBegan
    /// Input fired whenever a touch is moved on screen
    case touchesMoved
    /// Input fired whenever a touch event ends
    case touchesEnded
}
