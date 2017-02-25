//
//  GameEvent.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 05/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Represents a game event that is broadcaster through a game screen
public protocol GameEvent {
    
    /// Gets a unique string that is meant to describe this game event.
    /// Defaults to the name of the dynamic type of the implementer.
    static var eventIdentifier: String { get }
}

extension GameEvent {
    public static var eventIdentifier: String {
        return String(describing: self)
    }
}
