//
//  GPGameScene.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import SpriteKit

public func ==(lhs: GPGameSceneNotifier, rhs: GPGameSceneNotifier) -> Bool
{
    return lhs === rhs;
}

// Protocol to be implemented by systens, used to notify when
// entities are added/removed/modified in a GameScene
public class GPGameSceneNotifier: Equatable
{
    // Notifies when an entity was added to the scene. The return value depends on the class that implements it.
    public func gameSceneDidAddEntity(entity: GPEntity) -> Bool
    {
        return true;
    }
    // Notifies when an entity was removed from the scene. The return value depends on the class that implements it.
    public func gameSceneDidRemoveEntity(entity: GPEntity) -> Bool
    {
        return true;
    }
    
    // Notifies when the game scene has received a touches began event
    public func gameSceneDidReceiveTouchesBegan(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches ended event
    public func gameSceneDidReceiveTouchesEnded(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches moved event
    public func gameSceneDidReceiveTouchesMoved(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches cancelled event
    public func gameSceneDidReceiveTouchesCancelled(touches: NSSet, withEvent event: UIEvent) { }
    
    // Notifies when the game scene will be removed from the main view
    public func gameSceneWillBeMovedFromView() { }
    // Notifies when the game scene has been added to a view
    public func gameSceneDidAddToView() { }
    
    // Notifies when a collision between two physics objects has started on the game scene
    public func gameSceneDidBeginContact(contact: SKPhysicsContact) { }
    // Notifies when a collision between two physics objects has ended on the game scene
    public func gameSceneDidEndContact(contact: SKPhysicsContact) { }
}

// Defines a game scene object
public class GPGameScene: SKScene, SKPhysicsContactDelegate
{
    // The intenral list of systems
    private var _systems: [GPSystem] = [];
    
    /// The internal list of spaces
    private var _spaces: [GPSpace] = [];
    
    // The internal list of entities
    private var _entities: [GPEntity] = [];
    // A list of notifier objects
    private var _notifiers: [GPGameSceneNotifier] = [];
    // The world node
    private var _worldNode: SKNode;
    // The last update time interval tick. Used to calculate a delta time (time difference) between frames
    private var _lastUpdateTimeInterval: NSTimeInterval = 0;
    // The event dispatcher that handles event handling on the game screen
    private var _eventDispatcher: GPEventDispatcher = GPEventDispatcher();
    
    // Gets the world node of this game scene.
    //
    // World nodes are nodes that are one level above the game screen, and are utilized to make
    // transformation modifications to properties such as position, scale and rotation, and are
    // useful when making camera objects etc., since the SKScene node cannot have transformations
    // applied to them.
    public var worldNode: SKNode { return _worldNode; }
    
    // Gets the event dispatcher for this game scene
    public var eventDispatcher: GPEventDispatcher { return _eventDispatcher }
    
    public required init?(coder aDecoder: NSCoder)
    {
        self._worldNode = SKNode();
        super.init(coder: aDecoder);
    }
    
    public override init(size: CGSize)
    {
        self._worldNode = SKNode();
        super.init(size: size);
    }
    
    public override init()
    {
        self._worldNode = SKNode();
        super.init();
    }
    
    // Adds a notifier to this game scene
    public func addNotifier(notifier: GPGameSceneNotifier)
    {
        _notifiers += notifier;
    }
    
    // Removes a notifier from this game scene
    public func removeNotifier(notifier: GPGameSceneNotifier)
    {
        _notifiers.remove(notifier);
    }
    
    public func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval)
    {
        
    }
    
    public override func update(currentTime: NSTimeInterval)
    {
        // Handle time delta.
        // If we drop below 60fps, we still want everything to move the same distance.
        var timeSinceLast = currentTime - self._lastUpdateTimeInterval;
        self._lastUpdateTimeInterval = currentTime;
        
        if (timeSinceLast > 1)
        {
            // more than a second since last update
            timeSinceLast = 1.0 / 60.0;
            self._lastUpdateTimeInterval = currentTime;
        }
        
        self.updateWithTimeSinceLastUpdate(timeSinceLast);
    }
    
    public override func didEvaluateActions()
    {
        super.didEvaluateActions();
        
        for system in _systems
        {
            system.didEvaluateActions();
        }
    }
    
    public override func didSimulatePhysics()
    {
        super.didSimulatePhysics();
        
        for system in _systems
        {
            system.didSimulatePhysics();
        }
    }
    
    // Clears the cene, removing all the entities and systems associated
    public func clearScene()
    {
        while(_systems.count > 0)
        {
            self.removeSystem(self._systems[0]);
        }
        
        
    }
    
    // Returns an entity in this scene that matches the given ID
    public func getEntityByID(id: Int) -> GPEntity?
    {
        for entity in _entities
        {
            if(entity.id == id)
            {
                return entity;
            }
        }
        
        return nil;
    }
    // Returns a list of entities in this scene that match the given type
    public func getEntitiesByType(type: Int) -> [GPEntity]
    {
        var array: [GPEntity] = [];
        
        for entity in array
        {
            if((entity.type & type) != 0)
            {
                array += _entities;
            }
        }
        
        return array;
    }
    
    // Returns a list of enttiies in this game scene that were filtered with the given entity selector
    public func getEntitiesWithSelector(selector: GPEntitySelector) -> [GPEntity]
    {
        return selector.applyRuleToArray(_entities);
    }
    
    
    // Returns a list of enttiies in this game scene that were filtered with the given selector rule
    //- (NSArray*)getEntitiesWithSelectorRule:(GPSelectorRule*)rule
    public func getEntitiesWithSelectorRule(rule: GPSelectorRule) -> [GPEntity]
    {
        return self.getEntitiesWithSelector(GPEntitySelector(rule));
    }
    
    // Adds a given system to this game scene
    public func addSystem(system: GPSystem)
    {
        system.willAddToScene(self);
        
        self._systems += system;
        
        // Adds the system as a notifier for this game scene
        _notifiers += system;
        
        system.didAddToScene();
    }
    // Removes a system from this game scene
    public func removeSystem(system: GPSystem)
    {
        system.willRemoveFromScene();
        
        self._systems -= system;
        
        // Remove the system as a notifier
        self._notifiers -= system;
        
        system.didRemoveFromScene();
    }
    // Returns a system in this game scene that derives from a specific class
    public func getSystemWithType<T: GPSystem>(systemClass: T.Type) -> T?
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
    
    
    // Interface events
    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesBegan(touches, withEvent:event);
        }
    }
    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesEnded(touches, withEvent:event);
        }
    }
    public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesMoved(touches, withEvent:event);
        }
    }
    public override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent!)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesCancelled(touches, withEvent:event);
        }
    }
    public override func didMoveToView(view: SKView)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidAddToView();
        }
    }
    public override func willMoveFromView(view: SKView)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneWillBeMovedFromView();
        }
    }
    
    public func didBeginContact(contact: SKPhysicsContact)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidBeginContact(contact);
        }
    }
    public func didEndContact(contact: SKPhysicsContact)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidEndContact(contact);
        }
    }
}