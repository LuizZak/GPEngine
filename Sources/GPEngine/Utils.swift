//
//  Utils.swift
//  JelloSwift
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

extension RangeReplaceableCollection {
    
    /// Removes the first element in this collection where the given closure
    /// evaluates to true.
    /// This method also returns the element that was removed, if any.
    @discardableResult
    mutating func removeFirst(
        where closure: (Iterator.Element) throws -> Bool
    ) rethrows -> Iterator.Element? {
        
        var index = startIndex
        
        while index != endIndex {
            let element = self[index]
            if try closure(element) {
                remove(at: index)
                return element
            }
            
            index = self.index(after: index)
        }
        
        return nil
    }
}
