//
//  Utils.swift
//  JelloSwift
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

extension RangeReplaceableCollection {
    
    /// Removes the first element in this collection where the given closure
    /// evaluates to true
    mutating func removeFirst(where closure: (Iterator.Element) -> Bool) {
        var index = startIndex
        
        while index != endIndex {
            if closure(self[index]) {
                remove(at: index)
                break
            }
            
            index = self.index(after: index)
        }
    }
    
    /// Removes all elements in this collection where the given closure
    /// evaluates to true
    mutating func removeAll(where closure: (Iterator.Element) -> Bool) {
        var index = startIndex
        
        while index != endIndex {
            if closure(self[index]) {
                remove(at: index)
                continue
            }
            
            index = self.index(after: index)
        }
    }
}

extension RangeReplaceableCollection where Iterator.Element: Equatable {
    
    /// Removes a given equatable instance from this collection
    mutating func remove(_ object : Iterator.Element) {
        self.removeFirst(where: { $0 == object })
    }
}
