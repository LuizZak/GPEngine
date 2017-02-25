//
//  Game.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

/// Represents a game object, which is the core object of this engine.
/// Games contains spaces and systems, and manages the interactions between them.
open class Game: GameEventDispatcherDelegate {
    
    /// The list of spaces currently registered on this game
    internal(set) open var spaces: [Space]
    /// The list of systems that can manipulate the spaces
    internal(set) open var systems: [System]
    
    /// The last update time interval tick. Used to calculate a delta time (time
    /// difference) between frames
    fileprivate var lastUpdateTime: DeltaTimeInterval = 0
    
    /// The event dispatcher that handles event handling on the game
    internal(set) open var eventDispatcher: GameEventDispatcher = GameEventDispatcher()
    
    public init() {
        spaces = [Space]()
        systems = [System]()
        
        eventDispatcher.delegate = self
    }
    
    open func gameEventDispatcher(_ eventDispatcher: GameEventDispatcher, wihhDispatch event: GameEvent) {
        
        // Forward to spaces
        for space in spaces {
            space.eventDispatcher.dispatchEvent(event)
        }
    }
    
    /// Method called before each frame is rendered on the screen
    open func updateWithTimeSinceLastUpdate(_ timeSinceLast: DeltaTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    /// Updates this game object, with a specified time since the last frame in 
    /// milliseconds
    open func updateAndRender(_ dt: DeltaTimeInterval) {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same
        // distance.
        var timeSinceLast = dt - self.lastUpdateTime
        self.lastUpdateTime = dt
        
        if (timeSinceLast > 1) {
            // more than a second since last update
            timeSinceLast = 1.0 / 60.0
            self.lastUpdateTime = dt
        }
        
        self.updateWithTimeSinceLastUpdate(timeSinceLast)
        
        for system in systems {
            system.update(spaces: spaces.filter { $0.active }, interval: dt)
        }
    }
    
    /// Renders this game object
    open func render(_ dt: DeltaTimeInterval) {
        for system in systems {
            system.render(spaces: spaces.filter { $0.active }, interval: dt)
        }
    }
    
    /// Adds a space to the game
    open func addSpace(_ space: Space) {
        if(!spaces.contains(space)) {
            spaces.append(space)
        }
    }
    /// Removes a space from the game
    open func removeSpace(_ space: Space) {
        spaces.remove(space)
    }
    
    /// Adds a system to the game
    open func addSystem(_ system: System) {
        systems.append(system)
    }
    
    /// Adds a system to the game, but only if there are no systems of its type
    /// registered
    open func addSystemOnce<T: System>(_ system: T) {
        if(getSystem(ofType: T.self) == nil) {
            systems.append(system)
        }
    }
    
    /// Returns a system in the game that has the specified type, or nil, if
    /// none was found
    open func getSystem<T: System>(ofType type: T.Type) -> T? {
        for system in systems {
            if(system is T) {
                return system as? T
            }
        }
        
        return nil
    }
    
    /// Returns a value specifying whether a system with a given type exists
    /// on this game object
    open func hasSystem<T: System>(ofType type: T.Type) -> Bool {
        return systems.first { $0 is T } != nil
    }
    
    /// Removes a system from the game
    open func removeSystem(_ system: System) {
        systems.remove(system)
    }
}