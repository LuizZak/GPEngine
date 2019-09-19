#if !canImport(ObjectiveC)
import XCTest

extension EntitySelectorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__EntitySelectorTests = [
        ("testAndRuleEmpty", testAndRuleEmpty),
        ("testAndShortcut", testAndShortcut),
        ("testOrRuleEmpty", testOrRuleEmpty),
        ("testOrShortcut", testOrShortcut),
        ("testRuleAll", testRuleAll),
        ("testRuleAnd", testRuleAnd),
        ("testRuleComponent", testRuleComponent),
        ("testRuleId", testRuleId),
        ("testRuleNone", testRuleNone),
        ("testRuleNot", testRuleNot),
        ("testRuleOr", testRuleOr),
        ("testRuleType", testRuleType),
    ]
}

extension EntityTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__EntityTests = [
        ("testComponentAdd", testComponentAdd),
        ("testComponentGetType", testComponentGetType),
        ("testComponentRemove", testComponentRemove),
        ("testWithComponentsOfType", testWithComponentsOfType),
        ("testWithThreeComponentsOfType", testWithThreeComponentsOfType),
        ("testWithTwoComponentsOfType", testWithTwoComponentsOfType),
    ]
}

extension EventingTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__EventingTests = [
        ("testClosureEventListener", testClosureEventListener),
        ("testClosureGlobalEventListener", testClosureGlobalEventListener),
        ("testEventDispatch", testEventDispatch),
        ("testEventRemove", testEventRemove),
        ("testEventRemoveAll", testEventRemoveAll),
        ("testGlobalEventNotifier", testGlobalEventNotifier),
        ("testKeyInvalidateOnDispatcherDealloc", testKeyInvalidateOnDispatcherDealloc),
        ("testKeyInvalidateOnRemoveAllEvents", testKeyInvalidateOnRemoveAllEvents),
        ("testKeyInvalidateOnRemoveByKey", testKeyInvalidateOnRemoveByKey),
        ("testKeyInvalidateOnRemoveListener", testKeyInvalidateOnRemoveListener),
        ("testMultiEventAdd", testMultiEventAdd),
        ("testMultiListenersEventDispatch", testMultiListenersEventDispatch),
        ("testRemoveAllListeners", testRemoveAllListeners),
    ]
}

extension SpaceTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SpaceTests = [
        ("testAddSubspace", testAddSubspace),
        ("testAddSubspaceThatAlreadyHasSpace", testAddSubspaceThatAlreadyHasSpace),
        ("testRemoveSubspace", testRemoveSubspace),
        ("testWithSubspacesOfType", testWithSubspacesOfType),
    ]
}

extension SystemTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SystemTests = [
        ("testAddSystem", testAddSystem),
        ("testRemoveSystem", testRemoveSystem),
        ("testSystemByType", testSystemByType),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EntitySelectorTests.__allTests__EntitySelectorTests),
        testCase(EntityTests.__allTests__EntityTests),
        testCase(EventingTests.__allTests__EventingTests),
        testCase(SpaceTests.__allTests__SpaceTests),
        testCase(SystemTests.__allTests__SystemTests),
    ]
}
#endif
