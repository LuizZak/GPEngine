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
    
    /// A global event dispatcher.
    /// Events sent to this event dispatcher are automatically sunk into each
    /// space's inner event dispatcher automatically.
    ///
    /// Do not forward events from a space's event dispatcher to this dispatcher,
    /// as this will result in an infinite loop.
    internal(set) open var eventDispatcher: GameEventDispatcher = GameEventDispatcher()
    
    public init() {
        spaces = [Space]()
        systems = [System]()
        
        eventDispatcher.delegate = self
    }
    
    /// Sinks events from the main event dispatcher into all spaces
    open func gameEventDispatcher(_ eventDispatcher: GameEventDispatcher, willDispatch event: GameEvent) {
        
        // Forward to spaces
        for space in spaces {
            space.eventDispatcher.dispatchEvent(event)
        }
    }
    
    /// Updates this game object, with a specified time since the last frame in 
    /// milliseconds
    open func update(_ dt: DeltaTimeInterval) {
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
            
            // Forward events
            _=eventDispatcher.addListenerForAllEvents(space.eventDispatcher)
        }
    }
    /// Removes a space from the game
    open func removeSpace(_ space: Space) {
        if(spaces.contains(space)) {
            spaces.remove(space)
            
            // Dismount event listener
            eventDispatcher.removeListener(space.eventDispatcher)
        }
    }
    
    /// Adds a system to the game
    open func addSystem(_ system: System) {
        systems.append(system)
    }
    
    /// Adds a system to the game, but only if there are no systems of its type
    /// registered
    open func addSystemOnce<T: System>(_ system: T) {
        if(self.system(ofType: T.self) == nil) {
            systems.append(system)
        }
    }
    
    /// Returns a system in the game that has the specified type, or nil, if
    /// none was found
    open func system<T: System>(ofType type: T.Type) -> T? {
        for system in systems {
            if let s = system as? T {
                return s
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