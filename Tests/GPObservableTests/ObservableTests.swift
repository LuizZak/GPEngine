import XCTest
import GPObservable

class ObservableTests: XCTestCase {
    func testObservable() {
        var listenerValue: Int!
        let test = Test()
        _ = test.$value.addListener { value in
            listenerValue = value
        }
        
        test.value = 1
        
        XCTAssertEqual(listenerValue, 1)
    }
    
    func testObservableWeakLink() {
        var didCallListener: Bool = false
        let weakKey = Test()
        let test = Test()
        _ = test.$value.addListenerBorrowed(weakKey: WeakKey(key: weakKey)) { value in
            didCallListener = true
        }
        
        test.value = 1
        
        XCTAssert(didCallListener)
    }
    
    func testObservableWeakKeyDiscard() {
        var didCallListener: Bool = false
        var weakKey: Test? = Test()
        let test = Test()
        _ = test.$value.addListenerBorrowed(weakKey: WeakKey(key: weakKey)) { value in
            didCallListener = true
        }
        
        weakKey = nil
        test.value = 1
        
        XCTAssertFalse(didCallListener)
    }
}

class Test {
    @Observable var value: Int = 0
}
