/// An observable describes a stateful value holder that notifies listeners
/// whenever its state value has been changed.
@propertyWrapper
public final class Observable<T> {
    private var nextKey = 0
    private var listeners: [ListenerEntry] = []
    
    /// Gets or sets the value being observed.
    ///
    /// When setting, triggers listeners updating them of the new value.
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
    
    /// Returns this observable itself for creating listeners out of.
    public var projectedValue: Observable<T> {
        return self
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    /// Adds a strong listener closure that is retained along with the lifetime
    /// of this observable object and will be notified whenever the state has
    /// changed.
    public func addListener(_ listener: @escaping (T) -> Void) -> ListenerKey {
        let key = makeNextListenerKey()
        let listener = ListenerEntry(key: key, weakKey: nil, closure: listener)
        listeners.append(listener)
        
        return key
    }
    
    /// Adds a weak listener closure that is retained along with the lifetime
    /// of this observable object and will be notified whenever the state has
    /// changed, but which will be discarded if the weak key provided is released
    /// from memory.
    public func addListenerBorrowed(weakKey: WeakKey, _ listener: @escaping (T) -> Void) -> ListenerKey {
        let key = makeNextListenerKey()
        let listener = ListenerEntry(key: key, weakKey: weakKey, closure: listener)
        listeners.append(listener)
        
        return key
    }
    
    /// Requests that a listener with a specified key be removed from this
    /// observable object.
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

extension Observable: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
