import XCTest
@testable import GPEngineTests
@testable import SerializationTests

XCTMain([
    testCase(EntitySelectorRuleTests.allTests),
    testCase(EntityTests.allTests),
    testCase(EventingTests.allTests),
    testCase(SpaceTests.allTests),
    testCase(SystemTests.allTests),
    testCase(SerializationTests.allTests)
])
