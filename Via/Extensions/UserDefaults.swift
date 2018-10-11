import Foundation

extension UserDefaults {

    @discardableResult
    func set(_ value: Any?, key: Constants.UserDefaults) -> UserDefaults {
        set(value, forKey: key.rawValue)
        return self
    }

    @discardableResult
    func removeObject(key: Constants.UserDefaults) -> UserDefaults {
        removeObject(forKey: key.rawValue)
        return self
    }
}
