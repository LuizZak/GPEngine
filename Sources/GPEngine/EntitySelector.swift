//
//  SelectorRule.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Specifies a set of recursive rules for selecting entities using boolean
/// operations.
///
/// Evaluate entities with rules by using `rule.evaluate(with: entity)`.
public indirect enum EntitySelector {
    
    /// Selects no entities
    case none
    
    /// Selects any entity passed
    case any
    
    /// Reverses the result of a selector
    case not(EntitySelector)
    
    /// Selects if any of a set of selectors does.
    /// This selector short-circuits the operation, succeeding on the first
    /// rule that does.
    case or([EntitySelector])
    
    /// Selects only if all of a set of selectors do.
    /// This selector short-circuits the operation, failing on the first
    /// rule that does.
    case and([EntitySelector])
    
    /// Selects if a given component exists an the entity
    case component(Component.Type)
    
    /// Selects if an entity corresponds to a given id
    case id(Int)
    
    /// Selects if the entity's type flag conforms to a given type.
    /// Does a binary & to filter.
    case typeFlag(Int)
    
    /// Returns all entities from an array of entities that pass this selector
    @inlinable
    public func select<S: Sequence>(from entities: S) -> LazyFilterSequence<S> where S.Element == Entity {
        return entities.lazy.filter(evaluate(with:))
    }
    
    /// Evaluates a given entity using this selector
    @inlinable
    public func evaluate(with entity: Entity) -> Bool {
        switch self {
        case .none:
            return false
            
        case .any:
            return true
            
        case .not(let rule):
            return !rule.evaluate(with: entity)
            
        case .or(let rules):
            for rule in rules {
                if rule.evaluate(with: entity) {
                    return true
                }
            }
            
            return false
            
        case .and(let rules):
            if rules.isEmpty {
                return false
            }
            
            for rule in rules {
                if !rule.evaluate(with: entity) {
                    return false
                }
            }
            
            return true
            
        case .component(let type):
            return entity.hasComponent(ofType: type)
            
        case .id(let id):
            return entity.id == id
            
        case .typeFlag(let type):
            return entity.type & type != 0
        }
    }
    
    // MARK: Operators
    
    /// Creates a .and selector based on the combination of two entity selectors
    @inlinable
    public static func && (lhs: EntitySelector, rhs: EntitySelector) -> EntitySelector {
        // Shortcut: If lhs is already an 'and', compose it over the set of
        // rules there
        switch lhs {
        case .and(let rules):
            return .and(rules + [rhs])
        default:
            return .and([lhs, rhs])
        }
    }
    
    /// Creates an .or selector based on the combination of two entity selectors
    @inlinable
    public static func || (lhs: EntitySelector, rhs: EntitySelector) -> EntitySelector {
        // Shortcut: If lhs is already an 'or', compose it over the set of
        // rules there
        switch lhs {
        case .or(let rules):
            return .or(rules + [rhs])
        default:
            return .or([lhs, rhs])
        }
    }
    
    /// Creates a .not selector based on the given selector
    @inlinable
    public static prefix func ! (rule: EntitySelector) -> EntitySelector {
        // Shortcut: If the rule is already a 'not' rule, just unwrap it
        switch rule {
        case .not(let rule):
            return rule
        default:
            return .not(rule)
        }
    }
}
