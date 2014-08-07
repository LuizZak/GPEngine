//
//  GPSelectorRule.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import Foundation

// Specifies a base class to be implemented by selector rules
class GPSelectorRule
{
    // Applies the selector rule to an entity
    func applyRule(entity: GPEntity) -> Bool
    {
        return true;
    }
}

// Describes a selector rule that filter entities by components
class GPSRComponentSelector : GPSelectorRule
{
    var componentClass: GPComponent.Type;
    
    init(_ componentClass: GPComponent.Type)
    {
        self.componentClass = componentClass;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return entity.hasComponentType(componentClass);
    }
}

// Describes a selector rule that always returns false
class GPSRNone : GPSelectorRule
{
    override func applyRule(entity: GPEntity) -> Bool
    {
        return false;
    }
}

// Describes a selector rule that filters entities by ID
class GPSRIDSelector : GPSelectorRule
{
    var id : Int;
    
    init(_ id: Int)
    {
        self.id = id;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return entity.id == self.id;
    }
}

// Describes a selector rule that filters entities by type
class GPSRTypeSelector : GPSelectorRule
{
    var type: Int;
    
    init(_ id: Int)
    {
        self.type = id;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return (entity.type & self.type) != 0;
    }
}

// Describes a selector rule that groups two selector rules with an AND operation
// The operation is automatically short-circuited by the underlying runtime
class GPSRAndSelector : GPSelectorRule
{
    var firstRule: GPSelectorRule;
    var secondRule: GPSelectorRule;
    
    init(_ firstRule: GPSelectorRule, _ secondRule : GPSelectorRule)
    {
        self.firstRule = firstRule;
        self.secondRule = secondRule;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return firstRule.applyRule(entity) && secondRule.applyRule(entity);
    }
}

// Describes a selector rule that groups two selector rules with an OR operation
// The operation is automatically short-circuited by the underlying runtime
class GPSROrSelector : GPSelectorRule
{
    var firstRule: GPSelectorRule;
    var secondRule: GPSelectorRule;
    
    init(_ firstRule: GPSelectorRule, _ secondRule : GPSelectorRule)
    {
        self.firstRule = firstRule;
        self.secondRule = secondRule;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return firstRule.applyRule(entity) || secondRule.applyRule(entity);
    }
}

// Describes a selector rule that negates the result of another selector rule nested within it
class GPSRNotSelector : GPSelectorRule
{
    var rule: GPSelectorRule;
    
    init(_ firstRule: GPSelectorRule)
    {
        self.rule = firstRule;
    }
    
    override func applyRule(entity: GPEntity) -> Bool
    {
        return !rule.applyRule(entity);
    }
}