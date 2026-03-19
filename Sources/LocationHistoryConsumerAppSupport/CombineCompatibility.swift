import Foundation

#if !canImport(Combine)
public protocol ObservableObject: AnyObject {}

@propertyWrapper
public struct Published<Value> {
    public var wrappedValue: Value

    public var projectedValue: Published<Value> {
        self
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
#endif
