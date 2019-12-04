//
//  GameTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 06/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import XCTest
@testable import GPEngine

class GameTests: XCTestCase {
    var sut = Game()

    override func setUp() {
        super.setUp()
        sut = Game()
    }

    func testHasSystem() {
        XCTAssertFalse(sut.hasSystem(ofType: TestSystem.self))
        sut.addSystem(TestSystem())
        XCTAssert(sut.hasSystem(ofType: TestSystem.self))
    }

    func testAddSystem() {
        sut.addSystem(TestSystem())
        sut.addSystem(TestSystem())

        XCTAssertEqual(sut.systems.count, 2)
    }

    func testAddSystemOnce() {
        sut.addSystemOnce(TestSystem())
        sut.addSystemOnce(TestSystem())

        XCTAssertEqual(sut.systems.count, 1)
    }

    func testRemoveSystem() {
        let system = TestSystem()
        sut.addSystem(system)

        sut.removeSystem(system)

        XCTAssert(sut.systems.isEmpty)
    }

    func testSystemOfType() {
        XCTAssertNil(sut.system(ofType: TestSystem.self))

        let system = TestSystem()
        sut.addSystem(system)

        XCTAssert(sut.system(ofType: TestSystem.self) === system)
    }

    func testAddSpace() {
        let space = Space()
        sut.addSpace(space)

        XCTAssertEqual(sut.spaces.count, 1)
    }

    func testAddSpaceAddsSpaceOnlyOnce() {
        let space = Space()
        sut.addSpace(space)
        sut.addSpace(space)

        XCTAssertEqual(sut.spaces.count, 1)
    }

    func testRemoveSpace() {
        let space = Space()
        sut.addSpace(space)
        sut.removeSpace(space)

        XCTAssert(sut.spaces.isEmpty)
    }

    func testUpdateSystems() {
        let space = Space()
        let system = TestSystem()
        sut.addSpace(space)
        sut.addSystem(system)

        sut.update(1)

        XCTAssertEqual(system.updateInvocations.count, 1)
        XCTAssert(system.updateInvocations.first?.space === space)
        XCTAssert(system.updateInvocations.first?.deltaTime == 1)
    }

    func testRenderSystems() {
        let space = Space()
        let system = TestSystem()
        sut.addSpace(space)
        sut.addSystem(system)

        sut.render(1)

        XCTAssertEqual(system.renderInvocations.count, 1)
        XCTAssert(system.renderInvocations.first?.space === space)
        XCTAssert(system.renderInvocations.first?.deltaTime == 1)
    }

    func testGameEventDispatcherWillDispatchEvent() {
        var didInvokeEvent = false
        let space = Space()
        _ = space.eventDispatcher.addListener(ClosureEventListener<TestEvent> { _ in didInvokeEvent = true },
                                              forEventType: TestEvent.self)
        sut.addSpace(space)
        sut.gameEventDispatcher(sut.eventDispatcher, willDispatch: TestEvent())

        XCTAssert(didInvokeEvent)
    }
    
    func testGameEventDispatcherUnregistersSpaceOnRemoval() {
        var didInvokeEvent = false
        let space = Space()
        _ = space.eventDispatcher.addListener(ClosureEventListener<TestEvent> { _ in didInvokeEvent = true },
                                              forEventType: TestEvent.self)
        sut.addSpace(space)
        sut.removeSpace(space)
        sut.gameEventDispatcher(sut.eventDispatcher, willDispatch: TestEvent())

        XCTAssertFalse(didInvokeEvent)
    }
}

private class TestSystem: System {
    var updateInvocations: [(space: Space, deltaTime: DeltaTimeInterval)] = []
    var renderInvocations: [(space: Space, deltaTime: DeltaTimeInterval)] = []

    required init() {
        
    }

    func update(space: Space, interval deltaTime: DeltaTimeInterval) {
        updateInvocations.append((space, deltaTime))
    }

    func render(space: Space, interval deltaTime: DeltaTimeInterval) {
        renderInvocations.append((space, deltaTime))
    }
}

private class TestEvent: GameEvent {

}
