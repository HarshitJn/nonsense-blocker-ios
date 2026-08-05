import Foundation

/// A protocol abstraction for key-value persistence.
/// This allows us to use UserDefaults on iOS (with App Groups) and a Mock/InMemory store during tests.
public protocol KeyValueStore {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func integer(forKey defaultName: String) -> Int
    func double(forKey defaultName: String) -> Double
    func bool(forKey defaultName: String) -> Bool
    func removeObject(forKey defaultName: String)
}

/// Extension to make standard UserDefaults conform to KeyValueStore.
extension UserDefaults: KeyValueStore {}

/// A mock implementation of KeyValueStore for unit testing.
public class MockKeyValueStore: KeyValueStore {
    private var storage: [String: Any] = [:]

    public init() {}

    public func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }

    public func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }

    public func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] as? Int ?? 0
    }

    public func double(forKey defaultName: String) -> Double {
        return storage[defaultName] as? Double ?? 0.0
    }

    public func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }

    public func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
}
