import XCTest

import GPEngineTests
import SerializationTests

var tests = [XCTestCaseEntry]()
tests += GPEngineTests.__allTests()
tests += SerializationTests.__allTests()

XCTMain(tests)
