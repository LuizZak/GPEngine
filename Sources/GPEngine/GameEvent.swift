//
//  GameEvent.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

// Represents a game event that is broadcaster through a game screen
public protocol GameEvent {
    
    /// Gets a unique number that is meant to identify this game event.
    /// Defaults to the address in memory of the event's type.
    static var eventIdentifier: Int { get }
}

extension GameEvent {
    public static var eventIdentifier: Int {
        return unsafeBitCast(self, to: Int.self)
    }
}
