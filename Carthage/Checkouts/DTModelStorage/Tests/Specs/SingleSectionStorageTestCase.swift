//
//  SingleSectionStorageTestCase.swift
//  Tests
//
//  Created by Denys Telezhkin on 15.09.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import XCTest
#if canImport(Dwifft)
import Dwifft
#elseif canImport(Dwifft_tvOS)
import Dwifft_tvOS
#endif
import DTModelStorage
import HeckelDiff

class DwifftDiffer: EquatableDiffingAlgorithm {
    func diff<T:Identifiable & Equatable>(from: [T], to: [T]) -> [SingleSectionOperation] {
        let diffs = Dwifft.diff(from, to)
        return diffs.map {
            switch $0 {
            case .delete(let index, _):
                return SingleSectionOperation.delete(index)
            case .insert(let index, _):
                return SingleSectionOperation.insert(index)
            }
        }
    }
}

class HeckelDiffer : HashableDiffingAlgorithm {
    func diff<T>(from: [T], to: [T]) -> [SingleSectionOperation] where T : Identifiable, T : Hashable {
        let diffs = HeckelDiff.diff(from, to)
        return diffs.map {
            switch $0 {
            case .delete(let index):
                return SingleSectionOperation.delete(index)
            case .insert(let index):
                return SingleSectionOperation.insert(index)
            case .move(let old, let new):
                return SingleSectionOperation.move(from: old, to: new)
            case .update(let index):
                return SingleSectionOperation.update(index)
            }
        }
    }
}

extension String: Identifiable {
    public var identifier: AnyHashable {
        return self
    }
}

struct AnyIdentifiableEquatable: Identifiable, Equatable {
    let value : Any
    let equals: (Any) -> Bool
    let identifier: AnyHashable

    init<T:Identifiable & Equatable>(_ value: T) {
        self.value = value
        equals = {
            guard let instance = $0 as? T else { return false }
            return instance == value
        }
        identifier = value.identifier
    }

    static func == (lhs: AnyIdentifiableEquatable, rhs: AnyIdentifiableEquatable) -> Bool {
        return lhs.equals(rhs.value) || rhs.equals(lhs.value)
    }
}

struct Foo: Identifiable, Equatable {
    var identifier: AnyHashable { return 1 }
}

struct Bar: Identifiable, Equatable {
    var identifier: AnyHashable { return 2 }
}

struct UpdatableData : Equatable, Identifiable, Hashable {
    let id: Int
    let data: String
    
    var identifier: AnyHashable { return id }
    
    init(_ id: Int, _ data: String) {
        self.id = id
        self.data = data
    }
}

class SingleSectionStorageTestCase: XCTestCase {
    
    func verifyObjectChanges(_ observer: StorageUpdatesObserver, _ changes: [(ChangeType, [IndexPath])]) {
        XCTAssertEqual(observer.update?.objectChanges.count, changes.count)
        for (index, change) in changes.enumerated() {
            XCTAssertEqual(observer.update?.objectChanges[index].0, change.0)
            XCTAssertEqual(observer.update?.objectChanges[index].1, change.1)
        }
    }

    func testChangesAreCalculatableUsingEquatableDiffer() {
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionEquatableStorage(items: ["foo", "bar"], differ: DwifftDiffer())
        stringStorage.delegate = observer
        stringStorage.setItems(["bar", "foo"])
        
        verifyObjectChanges(observer, [
            (.delete, [indexPath(0, 0)]),
            (.insert, [indexPath(1, 0)]),
        ])

        observer.update?.applyDeferredDatasourceUpdates()

        XCTAssertEqual(stringStorage.items, ["bar", "foo"])
    }

    func testChangesAreCalculatedUsingHashableDiffer() {
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionHashableStorage(items: ["foo", "bar"], differ: HeckelDiffer())
        stringStorage.delegate = observer
        stringStorage.setItems(["bar", "foo"])

        verifyObjectChanges(observer, [
            (.move,  [indexPath(1, 0), indexPath(0, 0)]),
            (.move, [indexPath(0, 0), indexPath(1, 0)])
        ])

        observer.update?.applyDeferredDatasourceUpdates()

        XCTAssertEqual(stringStorage.items, ["bar", "foo"])
    }

    func testAdditionAccumulationStrategyIgnoresOldItems() {
        let items = [
            UpdatableData(1, "foo"),
            UpdatableData(2, "bar")
        ]
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionEquatableStorage(items: items, differ: DwifftDiffer())
        stringStorage.delegate = observer
        stringStorage.addItems([
            UpdatableData(1, "bar"),
            UpdatableData(3, "xyz")
        ])

        verifyObjectChanges(observer, [
            (.insert, [indexPath(2, 0)]),
            (.insert, [indexPath(3, 0)]),
        ])
    }

    func testUpdateOldValuesAccumulationStrategy() {
        let items = [
            UpdatableData(1, "foo"),
            UpdatableData(2, "bar")
        ]

        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionHashableStorage(items: items, differ: HeckelDiffer())
        stringStorage.delegate = observer
        stringStorage.addItems([UpdatableData(1, "bar"),
                               UpdatableData(3, "xyz")], UpdateOldValuesAccumulationStrategy())

        verifyObjectChanges(observer, [
                (.delete, [indexPath(0, 0)]),
                (.insert, [indexPath(0, 0)]),
                (.insert, [indexPath(2, 0)])
            ])

        observer.update?.applyDeferredDatasourceUpdates()

        XCTAssertEqual(stringStorage.items, [
                UpdatableData(1, "bar"),
                UpdatableData(2, "bar"),
                UpdatableData(3, "xyz")
            ])
    }

    func testDeleteOldValuesAccumulationStrategy() {
        let items = [
            UpdatableData(1, "foo"),
            UpdatableData(2, "bar")
        ]

        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionHashableStorage(items: items, differ: HeckelDiffer())
        stringStorage.delegate = observer
        stringStorage.addItems([UpdatableData(1, "bar"),
                                UpdatableData(3, "xyz")], DeleteOldValuesAccumulationStrategy())

        verifyObjectChanges(observer, [
            (.delete, [indexPath(0, 0)]),
            (.insert, [indexPath(1, 0)]),
            (.insert, [indexPath(2, 0)]),
            ])

        observer.update?.applyDeferredDatasourceUpdates()

        XCTAssertEqual(stringStorage.items, [
            UpdatableData(2, "bar"),
            UpdatableData(1, "bar"),
            UpdatableData(3, "xyz")
            ])
    }

    func testItemsAreSettableAndGettable() {
        let storage = SingleSectionEquatableStorage(items: ["1","2","3"], differ: DwifftDiffer())

        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? String, "1")
        XCTAssertEqual(storage.item(at: indexPath(2, 0)) as? String, "3")
        XCTAssertNil(storage.item(at: indexPath(3, 0)))
        XCTAssertNil(storage.item(at: indexPath(0, 1)))
    }

    func testSingleSectionStorageSupportsMultipleTypes() {
        let observer = StorageUpdatesObserver()
        let typeErasedInstances = [AnyIdentifiableEquatable(Foo()), AnyIdentifiableEquatable(Bar())]
        let storage = SingleSectionEquatableStorage(items: typeErasedInstances, differ: DwifftDiffer())
        storage.delegate = observer
        XCTAssertEqual(storage.items.count, 2)

        storage.addItems([AnyIdentifiableEquatable(Foo())])

        verifyObjectChanges(observer, [
            (.insert, [indexPath(2, 0)])
            ])

        observer.update?.applyDeferredDatasourceUpdates()

        XCTAssertEqual(storage.items.count, 3)
    }
}
