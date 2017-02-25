//
//  System.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

public func ==(lhs: System, rhs: System) -> Bool {
    return lhs === rhs
}

/// Describes a game system, that handles interactions between entities in a game scene
open class System: Equatable {
    
    /// The game associated with this system
    open weak var game: Game?
    
    /* NEW ENGINE UPDATE MEMBERS */
    public init(game: Game) {
        self.game = game
    }
    
    /// Updates all spaces provided
    open func update(spaces: [Space], interval deltaTime: TimeInterval) {
        for space in spaces {
            update(space: space, interval: deltaTime)
        }
    }
    
    /// Updates a specific space with this system.
    /// Called by update(spaces:interval:) individualy for every space passed in
    /// order
    open func update(space: Space, interval deltaTime: TimeInterval) {
        
    }
    
    /// Renders all spaces provided
    open func render(spaces: [Space], interval deltaTime: TimeInterval) {
        for space in spaces {
            render(space: space, interval: deltaTime)
        }
    }
    
    /// Renders a specific space with this system
    /// Called by render(spaces:interval:) individualy for every space passed in
    /// order
    open func render(space: Space, interval deltaTime: TimeInterval) {
        
    }
}
