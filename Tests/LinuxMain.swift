import XCTest

import GPEngineTests
import GPObservableTests
import SerializationTests

var tests = [XCTestCaseEntry]()
tests += GPEngineTests.__allTests()
tests += GPObservableTests.__allTests()
tests += SerializationTests.__allTests()

XCTMain(tests)
