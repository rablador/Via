import Foundation

extension Array {

    func filterDuplicatesOnAttribute(includeElement: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        var results = [Element]()

        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }

        return results
    }

    mutating func rearrange(fromIndex: Int, toIndex: Int) {
        let insertIndex = (toIndex < fromIndex) && (toIndex > 0) ? toIndex : toIndex
        let element = remove(at: fromIndex)
        insert(element, at: insertIndex)
    }
}

extension Array where Element == Favorite {

    func save() {
        var jsonToSave = [JSON]()
        forEach { favorite in
            jsonToSave.append(favorite.toJson())
        }

        UserDefaults.standard.set(jsonToSave, key: .favorites).synchronize()
        StopDataHandler.shared.favorites = self
    }
}

extension Array where Element == Commute {

    func save() {
        var jsonToSave = [JSON]()
        forEach { commute in
            jsonToSave.append(commute.toJson())
        }

        UserDefaults.standard.set(jsonToSave, key: .commutes).synchronize()
        StopDataHandler.shared.commutes = self
    }
}

extension Array where Element == Stop {

    func saveClosestOrigins() {
        let arrayToSave = Array(prefix(10))
        arrayToSave.saveStops(withKey: .closestOrigins)
        StopDataHandler.shared.closestOrigins = arrayToSave
    }

    func saveSearchedDestinations() {
        let arrayToSave = Array(prefix(10))
        arrayToSave.saveStops(withKey: .searchedDestinations)
        StopDataHandler.shared.searchedDestinations = arrayToSave
    }

    func saveSearchedOrigins() {
        let arrayToSave = Array(prefix(10))
        arrayToSave.saveStops(withKey: .searchedOrigins)
        StopDataHandler.shared.searchedOrigins = arrayToSave
    }

    func saveCurrentSearches() {
        let arrayToSave = Array(prefix(3))
        arrayToSave.saveStops(withKey: .currentSearches)
        StopDataHandler.shared.currentSearches = arrayToSave
    }

    private func saveStops(withKey key: Constants.UserDefaults) {
        var jsonToSave = [JSON]()
        forEach { jsonToSave.append($0.toJSON()) }

        UserDefaults.standard.set(jsonToSave, key: key)
    }
}
