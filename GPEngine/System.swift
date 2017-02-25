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
    
    /// Updates a specific space with this system
    open func update(space: Space, interval deltaTime: TimeInterval) {
        
    }
    
    /// Renders a specific space with this system
    open func render(space: Space, interval deltaTime: TimeInterval) {
        
    }
}
