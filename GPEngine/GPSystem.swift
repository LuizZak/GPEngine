//
//  GPSystem.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Describes a game system, that handles interactions between entities in a game scene
public class GPSystem: GPGameSceneNotifier
{
    // The game scene that contains this system
    public var gameScene: GPGameScene?;
    
    public var game: GPGame;
    
    /* NEW ENGINE UPDATE MEMBERS */
    public init(game: GPGame)
    {
        self.game = game;
        
        super.init();
    }
    
    /// Updates a specific space with this system
    public func update(space: GPSpace, _ deltaTime: NSTimeInterval)
    {
        
    }
    
    /// Renders a specific space with this system
    public func render(space: GPSpace)
    {
        
    }
    
    
    /*****************************/
    
    // Notifies that the system will be added to the given game scene.
    // This method is called before any modification is made to the state of the game scene.
    public func willAddToScene(gameScene: GPGameScene)
    {
        self.gameScene = gameScene;
    }
    
    // Notifies that the system has been successfully added to a game scene.
    // This method is called after all the state modifications have been made on the game scene.
    public func didAddToScene()
    {
        
    }
    
    // Notifies that the system will be removed from the curren game scene hosting it.
    // This method is called before any modification is made to the state of the game scene.
    public func willRemoveFromScene()
    {
        
    }
    
    // Notifies that the system has been removed from a game scene.
    // This method is called after all the state modifications have been made on the game scene.
    public func didRemoveFromScene()
    {
        // Clear all the entity references and clear the game scene reference
        self.gameScene = nil;
    }
    
    // Called by the game scene after all the actions have been processed
    public func didEvaluateActions()
    {
        
    }
    
    // Called by the game scene after the physics simulation has been updated
    public func didSimulatePhysics()
    {
        
    }
}