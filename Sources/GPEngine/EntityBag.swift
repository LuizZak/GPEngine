//
//  EntityBag.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 04/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Describes an object that bags entities from the game scene based on an
/// entity selector
struct EntityBag {
    
    /// The arrays of entities in this bag
    var entities: [Entity] = []
    
    /// The entity selector filtering out the entities on this bag
    var entitySelector: EntitySelector
    
    public init(selector: EntitySelector) {
        self.entitySelector = selector
    }
}
