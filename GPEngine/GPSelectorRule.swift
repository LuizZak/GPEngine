//
//  GPSelectorRule.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import Foundation

// Specifies a base class to be implemented by selector rules
public class GPSelectorRule
{
    // Applies the selector rule to an entity
    public func applyRule(entity: GPEntity) -> Bool
    {
        return true;
    }
}

// Describes a selector rule that filter entities by components
public class GPSRComponent : GPSelectorRule
{
    public var componentClass: GPComponent.Type;
    
    public init(_ componentClass: GPComponent.Type)
    {
        self.componentClass = componentClass;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return entity.hasComponentType(componentClass.self);
    }
}

// Describes a selector rule that always returns false
public class GPSRNone : GPSelectorRule
{
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return false;
    }
}

// Describes a selector rule that filters entities by ID
public class GPSREntityID : GPSelectorRule
{
    public var id : Int;
    
    public init(_ id: Int)
    {
        self.id = id;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return entity.id == self.id;
    }
}

// Describes a selector rule that filters entities by type
public class GPSRType : GPSelectorRule
{
    public var type: Int;
    
    public init(_ id: Int)
    {
        self.type = id;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return (entity.type & self.type) != 0;
    }
}

// Describes a selector rule that groups two selector rules with an AND operation
// The operation is automatically short-circuited by the underlying runtime
public class GPSRAnd : GPSelectorRule
{
    public var firstRule: GPSelectorRule;
    public var secondRule: GPSelectorRule;
    
    public init(_ firstRule: GPSelectorRule, _ secondRule : GPSelectorRule)
    {
        self.firstRule = firstRule;
        self.secondRule = secondRule;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return firstRule.applyRule(entity) && secondRule.applyRule(entity);
    }
}

// Describes a selector rule that groups two selector rules with an OR operation
// The operation is automatically short-circuited by the underlying runtime
public class GPSROr : GPSelectorRule
{
    public var firstRule: GPSelectorRule;
    public var secondRule: GPSelectorRule;
    
    public init(_ firstRule: GPSelectorRule, _ secondRule : GPSelectorRule)
    {
        self.firstRule = firstRule;
        self.secondRule = secondRule;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return firstRule.applyRule(entity) || secondRule.applyRule(entity);
    }
}

// Describes a selector rule that negates the result of another selector rule nested within it
public class GPSRNot : GPSelectorRule
{
    public var rule: GPSelectorRule;
    
    public init(_ firstRule: GPSelectorRule)
    {
        self.rule = firstRule;
    }
    
    public override func applyRule(entity: GPEntity) -> Bool
    {
        return !rule.applyRule(entity);
    }
}