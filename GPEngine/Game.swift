//
//  Game.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents a game object, which is the core object of this engine.
/// Games contains spaces and systems, and manages the interactions between them.
open class Game: UIResponder {
    
    /// The list of spaces currently registered on this game
    internal(set) open var spaces: [Space]
    /// The list of systems that can manipulate the spaces
    internal(set) open var systems: [System]
    
    /// The last update time interval tick. Used to calculate a delta time (time difference) between frames
    fileprivate var _lastUpdateTimeInterval: TimeInterval = 0
    
    /// The event dispatcher that handles event handling on the game
    internal(set) open var eventDispatcher: GameEventDispatcher = GameEventDispatcher()
    
    /// A custom optional view to dispatch along UI events
    var view: UIView?
    
    public override init() {
        spaces = [Space]()
        systems = [System]()
        
        super.init()
    }
    
    open func updateWithTimeSinceLastUpdate(_ timeSinceLast: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    /// Updates this game object, with a specified time since the last frame in milliseconds
    open func update(_ dt: TimeInterval) {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same distance.
        var timeSinceLast = dt - self._lastUpdateTimeInterval
        self._lastUpdateTimeInterval = dt
        
        if (timeSinceLast > 1) {
            // more than a second since last update
            timeSinceLast = 1.0 / 60.0
            self._lastUpdateTimeInterval = dt
        }
        
        self.updateWithTimeSinceLastUpdate(timeSinceLast)
        
        for space in spaces {
            if(space.active) {
                for system in systems {
                    system.update(space: space, interval: dt)
                }
            }
        }
    }
    
    /// Renders this game object
    open func render() {
        for space in spaces {
            if(space.active) {
                for system in systems {
                    system.render(space: space)
                }
            }
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
    /// Adds a system to the game, but only if there are no systems of its type registered
    open func addSystemOnce(_ system: System) {
        if(getSystemByType(type(of: system)) == nil) {
            systems.append(system)
        }
    }
    /// Returns a system in the game that has the specified type, or nil, if none was found
    open func getSystemByType<T: System>(_ type: T.Type) -> T? {
        for system in systems {
            if(system is T) {
                return system as? T
            }
        }
        
        return nil
    }
    
    /// Returns a value specifying whether a system with a given type exists on this game object
    open func hasSystemType<T: System>(_ type: T.Type) -> Bool {
        for system in systems {
            if(system is T) {
                return true
            }
        }
        
        return false
    }
    
    /// Removes a system from the game
    open func removeSystem(_ system: System) {
        systems.remove(system)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let event = TouchEvent(touches: touches, event: event!, eventType: TouchEventType.touchesBegan, view: view)
        
        for space in spaces {
            space.eventDispatcher.dispatchEvent(event)
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let event = TouchEvent(touches: touches, event: event!, eventType: TouchEventType.touchesMoved, view: view)
        
        for space in spaces {
            space.eventDispatcher.dispatchEvent(event)
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let event = TouchEvent(touches: touches, event: event!, eventType: TouchEventType.touchesEnded, view: view)
        
        for space in spaces {
            space.eventDispatcher.dispatchEvent(event)
        }
    }
}
