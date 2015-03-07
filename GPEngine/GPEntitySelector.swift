//
//  GPEntitySelector.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

// Describes an object that is capable of filtering a list of entities
// and return a new one that only contains objects that conform to a rule
public class GPEntitySelector
{
    // The base rule to apply
    public private(set) var baseRule: GPSelectorRule;
    
    public init(_ rule: GPSelectorRule)
    {
        self.baseRule = rule;
    }
    
    // Applies the selector rule to an array of entities, and returns
    // an array of entities that passed the test
    public func applyRuleToArray(objs: [GPEntity]) -> [GPEntity]
    {
        var out: [GPEntity] = [];
        
        for entity in objs
        {
            if(self.applyRuleToEntity(entity))
            {
                out += entity;
            }
        }
        
        return out;
    }
    
    // Applies the selector rule to a given entity
    public func applyRuleToEntity(entity: GPEntity) -> Bool
    {
        return baseRule.applyRule(entity);
    }
}