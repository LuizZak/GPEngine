//
//  GPGame.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents a game object, which is the core object of this engine.
/// Games contains spaces and systems, and manages the interactions between them.
public class GPGame
{
    /// The list of spaces currently registered on this game
    private var _spaces: [GPSpace];
    /// The list of systems that can manipulate the spaces
    private var _systems: [GPSystem];
    
    /// The event dispatcher that handles event handling on the game
    private var _eventDispatcher: GPEventDispatcher = GPEventDispatcher();
    
    /// Gets the event dispatcher for this game
    var eventDispatcher: GPEventDispatcher { return _eventDispatcher }
    
    /// The last update time interval tick. Used to calculate a delta time (time difference) between frames
    private var _lastUpdateTimeInterval: NSTimeInterval = 0;
    
    public init()
    {
        _spaces = [GPSpace]();
        _systems = [GPSystem]();
    }
    
    public func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        
    }
    
    /// Updates this game object, with a specified time since the last frame in milliseconds
    public func update(dt: NSTimeInterval)
    {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same distance.
        var timeSinceLast = dt - self._lastUpdateTimeInterval;
        self._lastUpdateTimeInterval = dt;
        
        if (timeSinceLast > 1)
        {
            // more than a second since last update
            timeSinceLast = 1.0 / 60.0;
            self._lastUpdateTimeInterval = dt;
        }
        
        self.updateWithTimeSinceLastUpdate(timeSinceLast);
        
        for space in _spaces
        {
            if(space.active)
            {
                for system in _systems
                {
                    system.update(space, dt);
                }
            }
        }
    }
    
    /// Renders this game object
    public func render()
    {
        for space in _spaces
        {
            if(space.active)
            {
                for system in _systems
                {
                    system.render(space);
                }
            }
        }
    }
    
    /// Adds a space to the game
    public func addSpace(space: GPSpace)
    {
        _spaces += space;
    }
    /// Removes a space from the game
    public func removeSpace(space: GPSpace)
    {
        _spaces -= space;
    }
    
    /// Adds a system to the game
    public func addSystem(system: GPSystem)
    {
        _systems += system;
    }
    /// Adds a system to the game, but only if there are no systems of its type registered
    public func addSystemOnce(system: GPSystem)
    {
        if(!_systems.contains(system))
        {
            _systems += system;
        }
    }
    /// Returns a system in the game that has the specified type, or nil, if none was found
    public func getSystemByType<T: GPSystem>(type: T.Type) -> T?
    {
        for system in _systems
        {
            if(system is T)
            {
                return system as? T;
            }
        }
        
        return nil;
    }
    /// Returns a value specifying whether a system with a given type exists on this game object
    public func hasSystemType<T: GPSystem>(type: T.Type) -> Bool
    {
        for system in _systems
        {
            if(system is T)
            {
                return true;
            }
        }
        
        return false;
    }
    
    /// Removes a system from the game
    public func removeSystem(system: GPSystem)
    {
        _systems -= system;
    }
}