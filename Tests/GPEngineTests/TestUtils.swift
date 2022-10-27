#if !os(macOS)

func autoreleasepool<T>(_ closure: () throws -> T) rethrows -> T {
    try closure()
}

#endif
