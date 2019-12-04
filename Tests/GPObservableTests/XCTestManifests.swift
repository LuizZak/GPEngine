#if !canImport(ObjectiveC)
import XCTest

extension ObservableTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ObservableTests = [
        ("testEncodeObservable", testEncodeObservable),
        ("testObservable", testObservable),
        ("testObservableWeakKeyDiscard", testObservableWeakKeyDiscard),
        ("testObservableWeakLink", testObservableWeakLink),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ObservableTests.__allTests__ObservableTests),
    ]
}
#endif
