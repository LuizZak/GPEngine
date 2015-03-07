//
//  GPEntityBag.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 04/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Describes an object that bags entities from the game scene based on an entity selector
public class GPEntityBag
{
    // The arrays of entities in this bag
    public var entities: [GPEntity] = [];
    // The entity selector filtering out the entities on this bag
    public var entitySelector: GPEntitySelector;
    
    public init(selector: GPEntitySelector)
    {
        self.entitySelector = selector;
    }
}