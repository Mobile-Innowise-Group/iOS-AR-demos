import Foundation

extension UserDefaults {
    struct Key<Value> {
        var name: String
    }
    
    subscript<T: Codable>(key: Key<T>) -> T? {
        get {
            if let data = UserDefaults.standard.object(forKey: key.name) as? Data,
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            } else {
                return value(forKey: key.name) as? T
            }
        }
        
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key.name)
            } else {
                setValue(newValue, forKey: key.name)
            }
        }
    }
    
    subscript<T: Codable>(key: Key<T>, default defaultProvider: @autoclosure () -> T) -> T {
        get {
            if let data = UserDefaults.standard.object(forKey: key.name) as? Data,
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            } else {
                return (value(forKey: key.name) as? T) ?? defaultProvider()
            }
        }
        
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key.name)
            } else {
                setValue(newValue, forKey: key.name)
            }
        }
    }
}
