public struct WeakKey {
    public weak var key: AnyObject?
    public var isExpired: Bool {
        return key == nil
    }
    
    public init(key: AnyObject?) {
        self.key = key
    }
}
