//
//  GPGameScene.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import SpriteKit

func ==(lhs: GPGameSceneNotifier, rhs: GPGameSceneNotifier) -> Bool
{
    return lhs.isEqual(rhs);
}

// Protocol to be implemented by systens, used to notify when
// entities are added/removed/modified in a GameScene
class GPGameSceneNotifier: NSObject, Equatable
{
    // Notifies when an entity was added to the scene. The return value depends on the class that implements it.
    func gameSceneDidAddEntity(entity: GPEntity) -> Bool
    {
        return true;
    }
    // Notifies when an entity was removed from the scene. The return value depends on the class that implements it.
    func gameSceneDidRemoveEntity(entity: GPEntity) -> Bool
    {
        return true;
    }
    
    // Notifies when the game scene has received a touches began event
    func gameSceneDidReceiveTouchesBegan(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches ended event
    func gameSceneDidReceiveTouchesEnded(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches moved event
    func gameSceneDidReceiveTouchesMoved(touches: NSSet, withEvent event: UIEvent) { }
    // Notifies when the game scene has received a touches cancelled event
    func gameSceneDidReceiveTouchesCancelled(touches: NSSet, withEvent event: UIEvent) { }
    
    // Notifies when the game scene will be removed from the main view
    func gameSceneWillBeMovedFromView() { }
    // Notifies when the game scene has been added to a view
    func gameSceneDidAddToView() { }
    
    // Notifies when a collision between two physics objects has started on the game scene
    func gameSceneDidBeginContact(contact: SKPhysicsContact) { }
    // Notifies when a collision between two physics objects has ended on the game scene
    func gameSceneDidEndContact(contact: SKPhysicsContact) { }
}

// Defines a game scene object
class GPGameScene: SKScene, SKPhysicsContactDelegate
{
    // The intenral list of systems
    private var _systems: [GPSystem] = [];
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
    var worldNode: SKNode { return _worldNode; }
    
    // Gets the event dispatcher for this game scene
    var eventDispatcher: GPEventDispatcher { return _eventDispatcher }
    
    required init?(coder aDecoder: NSCoder)
    {
        self._worldNode = SKNode();
        super.init(coder: aDecoder);
    }
    
    override init(size: CGSize)
    {
        self._worldNode = SKNode();
        super.init(size: size);
    }
    
    override init()
    {
        self._worldNode = SKNode();
        super.init();
    }
    
    // Adds a notifier to this game scene
    func addNotifier(notifier: GPGameSceneNotifier)
    {
        _notifiers += notifier;
    }
    
    // Removes a notifier from this game scene
    func removeNotifier(notifier: GPGameSceneNotifier)
    {
        _notifiers.remove(notifier);
    }
    
    func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval)
    {
        for system in _systems
        {
            system.update(timeSinceLast);
        }
    }
    
    override func update(currentTime: NSTimeInterval)
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
    
    override func didEvaluateActions()
    {
        super.didEvaluateActions();
        
        for system in _systems
        {
            system.didEvaluateActions();
        }
    }
    
    override func didSimulatePhysics()
    {
        super.didSimulatePhysics();
        
        for system in _systems
        {
            system.didSimulatePhysics();
        }
    }
    
    // Clears the cene, removing all the entities and systems associated
    func clearScene()
    {
        // Remove todos os sistemas
        while(_systems.count > 0)
        {
            self.removeSystem(self._systems[0]);
        }
        
        // Remove todas as entides
        while(_entities.count > 0)
        {
            self.removeEntity(self._entities[0]);
        }
    }
    
    // Adds an entity to this scene
    func addEntity(entity: GPEntity)
    {
        self.addEntity(entity, toNode: _worldNode);
    }
    // Adds an entity to this scene, adding it as a child of another node
    func addEntity(entity: GPEntity, toNode node:SKNode)
    {
        self._entities += entity;
        
        node.addChild(entity.node);
        
        entity.gameScene = self;
        
        // Fire the notifiers
        for notifier in self._notifiers
        {
            notifier.gameSceneDidAddEntity(entity);
        }
    }
    
    // Removes an entity from this scene
    func removeEntity(entity: GPEntity)
    {
        self._entities.remove(entity);
        
        entity.node.removeFromParent();
        
        if(entity.gameScene == self)
        {
            entity.gameScene = nil;
        }
        
        // Fire the notifiers
        for notifier in self._notifiers
        {
            notifier.gameSceneDidRemoveEntity(entity);
        }
    }
    // Returns an entity in this scene that matches the given ID
    func getEntityByID(id: Int) -> GPEntity?
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
    func getEntitiesByType(type: Int) -> [GPEntity]
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
    func getEntitiesWithSelector(selector: GPEntitySelector) -> [GPEntity]
    {
        return selector.applyRuleToArray(_entities);
    }
    
    
    // Returns a list of enttiies in this game scene that were filtered with the given selector rule
    //- (NSArray*)getEntitiesWithSelectorRule:(GPSelectorRule*)rule
    func getEntitiesWithSelectorRule(rule: GPSelectorRule) -> [GPEntity]
    {
        return self.getEntitiesWithSelector(GPEntitySelector(rule));
    }
    
    // Notifies that the given entity was structurally modified (components, id or type were modified)
    func entityModified(entity: GPEntity)
    {
        for system in _systems
        {
            system.entityModified(entity);
        }
    }
    
    // Adds a given system to this game scene
    func addSystem(system: GPSystem)
    {
        system.willAddToScene(self);
        
        self._systems += system;
        
        // Forces the system to load the relevant entities from this scene now
        system.reloadEntities(_entities);
        
        // Adds the system as a notifier for this game scene
        _notifiers += system;
        
        system.didAddToScene();
    }
    // Removes a system from this game scene
    func removeSystem(system: GPSystem)
    {
        system.willRemoveFromScene();
        
        self._systems -= system;
        
        // Remove the system as a notifier
        self._notifiers -= system;
        
        system.didRemoveFromScene();
    }
    // Returns a system in this game scene that derives from a specific class
    func getSystemWithType<T: GPSystem>(systemClass: T.Type) -> T?
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
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesBegan(touches, withEvent:event);
        }
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesEnded(touches, withEvent:event);
        }
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesMoved(touches, withEvent:event);
        }
    }
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidReceiveTouchesCancelled(touches, withEvent:event);
        }
    }
    override func didMoveToView(view: SKView)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidAddToView();
        }
    }
    override func willMoveFromView(view: SKView)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneWillBeMovedFromView();
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact!)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidBeginContact(contact);
        }
    }
    func didEndContact(contact: SKPhysicsContact!)
    {
        // Fire the notifiers
        for notifier in _notifiers
        {
            notifier.gameSceneDidEndContact(contact);
        }
    }
}