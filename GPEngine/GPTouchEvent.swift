//
//  GPInputEvent.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 10/03/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents an event fired whenever an input event happens
public class GPTouchEvent: GPEvent
{
    /// The type for this event
    public private(set) var eventType: GPTouchEventType;
    
    /// The touches for the event
    public private(set) var touches: Set<NSObject>;
    
    /// The event for the touch
    public private(set) var event: UIEvent;
    
    /// The view that the event was captured on
    public private(set) var view: UIView?;
    
    init(touches: Set<NSObject>, event: UIEvent, eventType: GPTouchEventType, view: UIView?)
    {
        self.eventType = eventType;
        self.touches = touches;
        self.event = event;
        self.view = view;
    }
}

/// The type for an input event
public enum GPTouchEventType
{
    /// Input fired whenever a touch event begins
    case TouchesBegan
    /// Input fired whenever a touch is moved on screen
    case TouchesMoved
    /// Input fired whenever a touch event ends
    case TouchesEnded
}