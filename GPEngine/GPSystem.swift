//
//  GPSystem.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Describes a game system, that handles interactions between entities in a game scene
class GPSystem: GPGameSceneNotifier
{
    // The game scene that contains this system
    var gameScene: GPGameScene?;
    // The list of entities currently being manipulated by this game system
    var entities: [GPEntity] = [];
    // The default entity selector for this game scene object
    var entitySelector: GPEntitySelector;
    
    override init()
    {
        self.entitySelector = GPEntitySelector(GPSRNone());
        
        super.init();
        
        self.entitySelector = self.createSelector();
    }
    
    func createSelector() -> GPEntitySelector
    {
        return GPEntitySelector(GPSRNone());
    }
    
    // Notifies that the system will be added to the given game scene.
    // This method is called before any modification is made to the state of the game scene.
    func willAddToScene(gameScene: GPGameScene)
    {
        self.gameScene = gameScene;
    }
    
    // Notifies that the system has been successfully added to a game scene.
    // This method is called after all the state modifications have been made on the game scene.
    func didAddToScene()
    {
        
    }
    
    // Notifies that the system will be removed from the curren game scene hosting it.
    // This method is called before any modification is made to the state of the game scene.
    func willRemoveFromScene()
    {
        
    }
    
    // Notifies that the system has been removed from a game scene.
    // This method is called after all the state modifications have been made on the game scene.
    func didRemoveFromScene()
    {
        // Clear all the entity references and clear the game scene reference
        self.entities = [];
        self.gameScene = nil;
    }
    
    // Called by the game scene to update the system state
    func update(interval: NSTimeInterval)
    {
        
    }
    
    // Called by the game scene after all the actions have been processed
    func didEvaluateActions()
    {
        
    }
    
    // Called by the game scene after the physics simulation has been updated
    func didSimulatePhysics()
    {
        
    }
    
    // Forces the system to reload the entities stored within it
    func reloadEntities(entities: [GPEntity])
    {
        self.entities = [];
        
        for entity in entities
        {
            if(self.testEntityToAdd(entity))
            {
                self.entities += entity;
            }
        }
    }
    
    // Called by the game scene, notifies that an entity has had its structural state modified (components, ID,
    // or type where modified)
    func entityModified(entity: GPEntity)
    {
        if(entities.contains(entity))
        {
            // Test if the entity does not fits the selector anymore
            if(!entitySelector.applyRuleToEntity(entity) && self.testEntityToRemove(entity))
            {
                entities.remove(entity);
            }
        }
        // Adiciona a entidade se ela passar no selector
        else if(self.testEntityToAdd(entity))
        {
            entities += entity;
        }
    }
    
    // Called when the system has to test an entity to add in its internal list of relevant entities
    func testEntityToAdd(entity: GPEntity) -> Bool
    {
        return entitySelector.applyRuleToEntity(entity);
    }
    
    // Called when the system has to test an entity to remove from its internal list of relevant entities
    func testEntityToRemove(entity: GPEntity) -> Bool
    {
        return self.entities.contains(entity);
    }
}