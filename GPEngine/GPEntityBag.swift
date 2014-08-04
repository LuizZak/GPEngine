//
//  GPEntityBag.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 04/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Describes an object that bags entities from the game scene based on an entity selector
class GPEntityBag: NSObject
{
    // The arrays of entities in this bag
    var entities: [GPEntity] = [];
    // The entity selector filtering out the entities on this bag
    var entitySelector: GPEntitySelector;
    
    init(_ entitySelector: GPEntitySelector)
    {
        self.entitySelector = entitySelector;
    }
}