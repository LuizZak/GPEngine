//
//  System.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// A protocol for representing game systems with
public protocol System: AnyObject {
    
    init()
    
    /// Updates all spaces provided
    @inlinable
    func update(spaces: [Space], interval deltaTime: DeltaTimeInterval)
    
    /// Updates a specific space with this system.
    /// Called by update(spaces:interval:) individualy for every space passed in
    @inlinable
    func update(space: Space, interval deltaTime: DeltaTimeInterval)
    
    /// Renders all spaces provided
    @inlinable
    func render(spaces: [Space], interval deltaTime: DeltaTimeInterval)
    
    /// Renders a specific space with this system
    /// Called by render(spaces:interval:) individualy for every space passed in
    @inlinable
    func render(space: Space, interval deltaTime: DeltaTimeInterval)
}

public extension System {
    
    /// Updates all spaces provided
    func update(spaces: [Space], interval deltaTime: DeltaTimeInterval) {
        for space in spaces {
            update(space: space, interval: deltaTime)
        }
    }
    
    /// Renders all spaces provided
    func render(spaces: [Space], interval deltaTime: DeltaTimeInterval) {
        for space in spaces {
            render(space: space, interval: deltaTime)
        }
    }
}
