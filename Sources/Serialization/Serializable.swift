@propertyWrapper
struct _Serializable<T: Serializable> {
    var wrappedValue: T
}
