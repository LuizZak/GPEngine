//
//  SpaceTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 01/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GPEngine

class SpaceTests: XCTestCase {
    func testAddSubspace() {
        let space = Space()
        let subspace = Subspace()
        
        space.addSubspace(subspace)
        
        XCTAssert(subspace.space === space)
        XCTAssert(space.subspaces.contains { $0 === subspace })
    }
    
    func testRemoveSubspace() {
        let space = Space()
        let subspace = Subspace()
        space.addSubspace(subspace)
        
        space.removeSubspace(subspace)
        
        XCTAssertNil(subspace.space)
        XCTAssertFalse(space.subspaces.contains { $0 === subspace })
    }
    
    func testAddSubspaceThatAlreadyHasSpace() {
        let space1 = Space()
        let space2 = Space()
        let subspace = Subspace()
        
        space1.addSubspace(subspace)
        space2.addSubspace(subspace)
        
        XCTAssert(subspace.space === space2)
        XCTAssertFalse(space1.subspaces.contains { $0 === subspace })
        XCTAssert(space2.subspaces.contains { $0 === subspace })
    }
    
    func testWithSubspacesOfType() {
        let space = Space()
        let subspace = Subspace()
        space.addSubspace(subspace)
        
        var fireCount = 0
        space.withSubspaces(ofType: Subspace.self) { _ in
            fireCount += 1
        }
        
        XCTAssertEqual(fireCount, 1)
    }
}
