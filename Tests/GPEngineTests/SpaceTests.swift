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
    let allTests = [
        ("testAddSubspace", testAddSubspace),
        ("testRemoveSubspace", testRemoveSubspace),
        ("testAddSubspaceThatAlreadyHasSpace", testAddSubspaceThatAlreadyHasSpace)
    ]
    
    func testAddSubspace() {
        let space = Space()
        let subspace = Subspace()
        
        space.addSubspace(subspace)
        
        XCTAssertEqual(subspace.space, space)
        XCTAssert(space.subspaces.contains(subspace))
    }
    
    func testRemoveSubspace() {
        let space = Space()
        let subspace = Subspace()
        
        space.addSubspace(subspace)
        
        space.removeSubspace(subspace)
        
        XCTAssertNil(subspace.space)
        XCTAssertFalse(space.subspaces.contains(subspace))
    }
    
    func testAddSubspaceThatAlreadyHasSpace() {
        let space1 = Space()
        let space2 = Space()
        let subspace = Subspace()
        
        space1.addSubspace(subspace)
        
        space2.addSubspace(subspace)
        
        XCTAssertEqual(subspace.space, space2)
        XCTAssertFalse(space1.subspaces.contains(subspace))
        XCTAssert(space2.subspaces.contains(subspace))
    }
}
