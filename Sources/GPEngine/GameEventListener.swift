//
//  GameEventReceiver.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// A protocol to be implemented by classed that receive events fired by the
/// game screen
public protocol GameEventListener {
    
    /// Receives an event fired by the game screen
    func receiveEvent(_ event: GameEvent)
}

/// Basic event listener that fires a closure whenever an expected event type
/// is received
public struct ClosureEventListener<Event: GameEvent>: GameEventListener {
    
    /// Closure to fire by this closure listener
    public var closure: (Event) -> Void
    
    public init(closure: @escaping (Event) -> Void) {
        self.closure = closure
    }
    
    /// Receives an event fired by the game screen
    public func receiveEvent(_ event: GameEvent) {
        if let event = event as? Event {
            closure(event)
        }
    }
}

/// A type-erased closure event listener.
/// Can be used to subscribe to all events dispatched by an event dispatcher
public struct ClosureAnyEventListener: GameEventListener {
    
    /// Closure to fire by this closure listener
    public var closure: (GameEvent) -> Void
    
    public init(closure: @escaping (GameEvent) -> Void) {
        self.closure = closure
    }
    
    /// Receives an event fired by the game screen
    public func receiveEvent(_ event: GameEvent) {
        closure(event)
    }
}
