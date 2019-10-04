@propertyWrapper
public final class Observable<T> {
    private var nextKey = 0
    private var listeners: [ListenerEntry] = []
    
    public var wrappedValue: T {
        didSet {
            for listener in listeners {
                if listener.weakKey?.isExpired == true {
                    continue
                }
                
                listener.closure(wrappedValue)
            }
            
            listeners.removeAll(where: { $0.weakKey?.isExpired == true })
        }
    }
    
    public var projectedValue: Observable<T> {
        return self
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public func addListener(_ listener: @escaping (T) -> Void) -> ListenerKey {
        let key = makeNextListenerKey()
        let listener = ListenerEntry(key: key, weakKey: nil, closure: listener)
        listeners.append(listener)
        
        return key
    }
    
    public func addListenerBorrowed(weakKey: WeakKey, _ listener: @escaping (T) -> Void) -> ListenerKey {
        let key = makeNextListenerKey()
        let listener = ListenerEntry(key: key, weakKey: weakKey, closure: listener)
        listeners.append(listener)
        
        return key
    }
    
    public func removeListener(withKey key: ListenerKey) {
        listeners.removeAll(where: { $0.key == key })
    }
    
    func makeNextListenerKey() -> ListenerKey {
        nextKey += 1
        return ListenerKey(key: nextKey)
    }
    
    struct ListenerEntry {
        var key: ListenerKey
        var weakKey: WeakKey?
        var closure: (T) -> Void
        
        var isWeakKeyed: Bool {
            return weakKey != nil
        }
    }
}

extension Observable: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Observable: Decodable where T: Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init(wrappedValue: try T.init(from: decoder))
    }
}

extension Observable: Equatable where T: Equatable {
    public static func == (lhs: Observable, rhs: Observable) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}
