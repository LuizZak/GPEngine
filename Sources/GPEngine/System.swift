//
//  System.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Describes a game system, that handles interactions between entities in a
/// game scene
open class System: Equatable {
    
    public init() {
        
    }
    
    /// Updates all spaces provided
    open func update(spaces: [Space], interval deltaTime: DeltaTimeInterval) {
        for space in spaces {
            update(space: space, interval: deltaTime)
        }
    }
    
    /// Updates a specific space with this system.
    /// Called by update(spaces:interval:) individualy for every space passed in
    /// order
    open func update(space: Space, interval deltaTime: DeltaTimeInterval) {
        
    }
    
    /// Renders all spaces provided
    open func render(spaces: [Space], interval deltaTime: DeltaTimeInterval) {
        for space in spaces {
            render(space: space, interval: deltaTime)
        }
    }
    
    /// Renders a specific space with this system
    /// Called by render(spaces:interval:) individualy for every space passed in
    /// order
    open func render(space: Space, interval deltaTime: DeltaTimeInterval) {
        
    }
    
    /// Performs a reference-equality check between two System instances.
    /// Parameter are equal if they reference the same object.
    static public func ==(lhs: System, rhs: System) -> Bool {
        return lhs === rhs
    }
}
