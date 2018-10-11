# Change Log
All notable changes to this project will be documented in this file.

# Next

## [6.3.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.3.0)

### Added

* Anomaly-detecting and reporting system for `DTCollectionViewManager`. Read more about it in [Anomaly Handler Readme section](https://github.com/DenHeadless/DTCollectionViewManager#anomaly-handler). Anomaly handler system **requires Swift 4.1 and higher**.
* Support for Swift 4.2 in Xcode 10 (beta 1).

### Changed

* Calling `startManaging(withDelegate:_)` method is no longer required.

### Breaking

* `viewFactoryErrorHandler` property on `DTCollectionViewManager` was removed, all supported errors and warnings are now a part of anomaly reporting system

## [6.1.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.1.1)

## [6.1.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.1.0)

## [6.1.0-beta.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.1.0-beta.1)

* Implemented new system for deferring datasource updates until `performBatchUpdates` block. This system is intended to fight crash, that might happen when `performBatchUpdates` method is called after `UITableView.reloadData` method(for example after calling `memoryStorage.setItems`, and then immediately `memoryStorage.addItems`). This issue is detailed in https://github.com/DenHeadless/DTCollectionViewManager/issues/27 and https://github.com/DenHeadless/DTCollectionViewManager/issues/23. This crash can also happen, if iOS 11 API `UITableView.performBatchUpdates` is used. This system is turned on by default. If, for some reason, you want to disable it and have old behavior, call:

```swift
manager.memoryStorage.defersDatasourceUpdates = false
```

Please note, though, that new default behavior is recommended, because it is more stable and works the same on both UITableView and UICollectionView.

* `collectionViewUpdater` property on `DTCollectionViewManager` is now of `CollectionViewUpdater` type instead of opaque `StorageUpdating` type. This should ease use of this object and prevent type unneccessary type casts.

## [6.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.0.0)

* Updated for Xcode 9.1 / Swift 4.0.2

## [6.0.0-beta.3](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.0.0-beta.3)

* Makes `DTCollectionViewManager` property weak instead of unowned to prevent iOS 10-specific memory issues/crashes.

## [6.0.0-beta.2](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.0.0-beta.2)

* Build with Xcode 9.0 final release.
* Fixed partial-availability warnings.

## [6.0.0-beta.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/6.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTTableViewManager 6.0 Migration Guide](https://github.com/DenHeadless/DTTableViewManager/blob/master/Documentation/DTTableViewManager%206.0%20Migration%20Guide.md)**

* Added `updateVisibleCells(_:) method`, that allows updating cell data for visible cells with callback on each cell. This is more efficient than calling `reloadData` when number of elements in `UICollectionView` does not change, and only contents of items change.
* Implement `configureEvents(for:_:)` method, that allows batching in several cell events to avoid using T.ModelType for events, that do not have cell created.
* Added `DTCollectionViewDropPlaceholderContext` wrapper with convenience support for UICollectionView placeholders.
* Implemented `UICollectionViewDragDelegate` and `UICollectionViewDropDelegate` events.
* Added 10 more `UICollectionViewDelegate` and `UICollectionViewDelegateFlowLayout` events.
* Added missing events for `UICollectionViewDatasource` protocol: `collectionView:moveItemAt:to:`, `indexTitlesFor:`, `collectionView:indexPathForIndexTitle:at:`
* Implemented conditional mappings
* `UICollectionViewDelegate` and `UICollectionViewDatasource` implementations have been refactored from `DTCollectionViewManager` to `DTCollectionViewDelegate` and `DTCollectionViewDataSource` classes.
* Added `DTCollectionViewNonOptionalManageable` protocol, that can be used with non-optional `UICollectionView` properties on your managed instance.

## [5.3.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.3.1)

* Initial support for Swift 3.2 (Xcode 9 beta-1).
* Fixed `registerNiblessHeader` and `registerNiblessFooter` to properly call nibless supplementary methods.

## [5.3.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.3.0)

* Use new events system from `DTModelStorage`, that allows events to be properly called for cells, that are created using `ViewModelMappingCustomizing` protocol.

## [5.2.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.2.0)

* Setting `CollectionViewUpdater` instance to `collectionViewUpdater` property on `DTCollectionViewManager` now triggers `didUpdateContent` closure on `CollectionViewUpdater`.

## [5.1.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.1.0)

Dependency changelog -> [DTModelStorage 4.0.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

* `CollectionViewUpdater` has been rewritten to use new `StorageUpdate` properties that track changes in order of their occurence.
* `CollectionViewUpdater` `reloadItemClosure` and `DTCollectionViewManager` `updateCellClosure` now accept indexPath and model instead of just indexPath. This is done because update may happen after insertions and deletions and object that needs to be updated may exist on different indexPath.

## [5.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.0.0)

No changes

## [5.0.0-beta.2](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.0.0-beta.2)

* Enables `RealmStorage` from `DTModelStorage` dependency.

## [5.0.0-beta.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/5.0.0-beta.1)

This is a major release, written in Swift 3. Read [Migration guide](Documentation/DTCollectionViewManager 5 migration guide.md) with descriptions of all features and changes.

Dependency changelog -> [DTModelStorage 3.0.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

### Added

* New events system that covers almost all available `UICollectionViewDelegate`, `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` delegate methods.
* New class - `CollectionViewUpdater`, that is calling all animation methods for `UICollectionView` when required by underlying storage.
* `updateCellClosure` method on `DTCollectionViewManager`, that manually updates visible cell instead of calling `collectionView.reloadItemsAt(_:)` method.
* `coreDataUpdater` property on `DTCollectionViewManager`, that creates `CollectionViewUpdater` object, that follows Apple's guide for updating `UICollectionView` from `NSFetchedResultsControllerDelegate` events.
* `isManagingCollectionView` property on `DTCollectionViewManager`.
* `unregisterCellClass(_:)`, `unregisterHeaderClass(_:)`, `unregisterFooterClass(_:)`, `unregisterSupplementaryClass(_:forKind:)` methods to unregister mappings from `DTCollectionViewManager` and `UICollectionView`

### Changed

* Swift 3 API Design guidelines have been applied to all public API.
* Event system is migrated to new `EventReaction` class from `DTModelStorage`
* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTCollectionViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTCollectionViewManager` instance.

### Removals

* `viewBundle` property on `DTCollectionViewManager`
* `itemForVisibleCell`, `itemForCellClass:atIndexPath:`, `itemForHeaderClass:atSectionIndex:`, `itemForFooterClass:atSectionIndex:` were removed - they were not particularly useful and can be replaced with much shorter Swift conditional typecasts.
* All events methods with method pointer semantics. Please use block based methods instead.
* `registerCellClass:whenSelected` method, that was tightly coupling something that did not need coupling.

## [4.8.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.8.0)

### Changed

* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTCollectionViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTCollectionViewManager` instance.

### Deprecations

* `viewBundle` property on `DTCollectionViewManager`

## [4.7.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.7.0)

Dependency changelog -> [DTModelStorage 2.6.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## [4.6.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.6.0)

Dependency changelog -> [DTModelStorage 2.5 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

### Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [4.5.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.5.0)

Dependency changelog -> [DTModelStorage 2.4 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## Added

* Support for Realm database storage - using `RealmStorage` class.
* `batchUpdatesInProgress` property on `DTCollectionViewManager` that indicates if batch updates are finished or not.  

## Changed

* UIReactions now properly unwrap data models, even for cases when model contains double optional value.

## [4.4.2](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.4.2)

## Fixed

* Fixed a rare crash, that could happen when new items are being added to UICollectionView prior to UICollectionView calling any delegate methods

## [4.4.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.4.1)

## Fixed

* Issue with Swift 2.1.1 (XCode 7.2) where storage.delegate was not set during initialization

## [4.4.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.4.0)

Dependency changelog -> [DTModelStorage 2.3 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve mapping system and error reporting.

## Added

* [New mapping system](https://github.com/DenHeadless/DTCollectionViewManager#data-models) with support for protocols and subclasses
* Mappings can now be [customized](https://github.com/DenHeadless/DTCollectionViewManager#customizing-mapping-resolution) using `DTViewModelMappingCustomizable` protocol.
* [Custom error handler](https://github.com/DenHeadless/DTCollectionViewManager#error-reporting) for `DTTableViewFactoryError` errors.

## Changed

* preconditionFailures have been replaced with `DTCollectionViewFactoryError` ErrorType
* Internal `CollectionViewReaction` class have been replaced by `UIReaction` class from DTModelStorage.

## [4.3.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.3.0)

Dependency changelog -> [DTModelStorage 2.2 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## Changed

* Added support for AppleTV platform (tvOS)

## Fixed

* Footer and supplementary configuration closures and method pointers

## Changed

* Improved failure cases for situations where cell or supplementary mappings were not found

## [4.2.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.2.1)

### Updated

* Improved stability by treating UICollectionView as optional

## [4.2.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.2.0)

Dependency changelog -> [DTModelStorage 2.1 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve storage updates and UI animation with UICollectionView. To make this happen, `DTModelStorage` classes were rewritten and rearchitectured, allowing finally to remove truly [historic workaround](https://github.com/DenHeadless/DTCollectionViewManager/commit/19ae8337b1f6442d1bd588b482d24395e99a2259#diff-7a0b0d0332a60e359c3b8e67a4034f09L674). This code was initially written to fix first item insertion and deletion of items in UICollectionView. Somewhere between iOS 6 and iOS 8 Apple has fixed bugs, that caused this behaviour to happen. This is not documented, and was not mentioned anywhere, and i was very lucky to find this out by accident. So finally, I was able to remove these workarounds(which by the way are almost [two years old](https://github.com/DenHeadless/DTCollectionViewManager/commit/0a4a33ba69a8a9752e84ffbf8f2d5c84ed8cd2aa)), and UICollectionView UI updates code is as clean as UITableView UI updates code.

There are some backwards-incompatible changes in this release, however Xcode quick-fix tips should guide you through what needs to be changed.

## Added

 * `registerNiblessCellClass` and `registerNiblessSupplementaryClass` methods to  support creating cells and supplementary views from code

## Bugfixes

* Fixed `cellConfiguration` method, that was working incorrectly
* Fixed retain cycles in event blocks

## [4.1.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.1.0)

## Features

New events registration system with method pointers, that automatically breaks retain cycles.

For example, cell selection:

```swift
manager.cellSelection(PostsViewController.selectedCell)

func selectedCell(cell: PostCell, post: Post, indexPath: NSIndexPath) {
    // Do something, push controller probably?
}
```

Alternatively, you can use dynamicType to register method pointer:

```swift
manager.cellSelection(self.dynamicType.selectedCell)
```

Other available events:
* cellConfiguration
* headerConfiguration
* footerConfiguration
* supplementaryConfiguration

## Breaking changes

`beforeContentUpdate` and `afterContentUpdate` closures were replaced with `DTCollectionViewContentUpdatable` protocol, that can be adopted by your `DTCollectionViewManageable` class, for example:

```swift
extension PostsViewController: DTCollectionViewContentUpdatable {
    func afterContentUpdate() {
        // Do something
    }
}
```

## [4.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/4.0.0)

4.0 is a next major release of `DTCollectionViewManager`. It was rewritten from scratch in Swift 2 and is not backwards-compatible with previous releases.

Read  [4.0 Migration guide](https://github.com/DenHeadless/DTCollectionViewManager/wiki/4.0-Migration-Guide).

[Blog post](http://digginginswift.com/2015/09/13/dttableviewmanager-4-protocol-oriented-uitableview-management-in-swift/)

### Features

* Improved `ModelTransfer` protocol with associated `ModelType`
* `DTCollectionViewManager` is now a separate object
* New events system, that allows reacting to cell selection, cell/header/footer configuration and content updates
* Added support for `UICollectionViewController`, and any other object, that has `UICollectionView`
* New storage object generic-type getters
* Support for Swift types - classes, structs, enums, tuples.


## [3.2.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.2.0)

### Bugfixes

* Fixed an issue, where storageDidPerformUpdate method could be called without any updates.

## [3.1.1](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.1.1)

* Added support for installation using [Carthage](https://github.com/Carthage/Carthage) :beers:

## [3.1.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.1.0)

## Changes

* Added nullability annotations for XCode 6.3 and Swift 1.2

## [3.0.5](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.0.5)

## Bugfixes

Fixed issue, that could lead to wrong collection items being removed, when using memory storage  removeItemsAtIndexPaths: method.

## [3.0.2](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.0.2)

## Features

Added support for installation as a framework via CocoaPods - requires iOS 8 and higher deployment target.

## [3.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/3.0.0)

3.0 is a next major release of DTCollectionViewManager. Read all about changes in detail on a [wiki page](https://github.com/DenHeadless/DTCollectionViewManager/wiki/DTCollectionViewManager-3.0.-What's-new%3F).

### Features
* Full Swift support, including swift model classes
* Added convenience method to update section items
* Added `DTCollectionViewControllerEvents` protocol, that allows developer to react to changes in datasource
* Added several convenience method for UICollectionViewFlowLayout. The API for supplementary header and footer registration now matches the API of DTTableViewManager.
* Added `collectionHeaderModel` and `collectionFooterModel` accessors for `DTSectionModel`.

### Breaking changes

* `DTStorage` protocol was renamed to `DTStorageProtocol`.

## [2.7.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.7.0)

This is a release, that is targeted at improving code readability, and reducing number of classes and protocols inside DTCollectionViewManager architecture.

### Breaking changes

* `DTCollectionViewMemoryStorage` class was removed. It's methods were transferred to `DTMemoryStorage+DTCollectionViewManagerAdditions` category.
* `DTCollectionViewStorageUpdating` protocol was removed. It's methods were moved to `DTCollectionViewController`.

### Features

* When using `DTCoreDataStorage`, section titles are displayed as headers by default(UICollectionElementKindSectionHeader), if NSFetchedController was created with sectionNameKeyPath property.


## [2.6.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.6.0)

## Features

Add ability to use custom xibs for collection view cells and supplementary views.

## [2.5.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.5.0)

### Changes

Preliminary support for Swift.

If you use cells or supplementary views inside storyboards from Swift, implement optional reuseIdentifier method to return real Swift class name instead of the mangled one. This name should also be set as reuseIdentifier in storyboard.

## [2.4.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.4.0)

### Breaking changes

Reuse identifier now needs to be identical to cell, header or footer class names. For example, UserTableCell should now have "UserTableCell" reuse identifier.

## [2.3.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.3.0)

### Deprecations

Removed `DTModelSearching` protocol, please use `DTMemoryStorage` `setSearchingBlock:forModelClass:` method instead.

## [2.2.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.2.0)

* `DTModelSearching` protocol is deprecated and is replaced by memoryStorage method setSearchingBlock:forModelClass:
* UICollectionViewDatasource and UICollectionViewDelegate properties for UITableView are now filled automatically.
* Added more assertions, programmer errors should be more easily captured.

## [2.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.0.0)

* DTModelTransfer and DTModelSearching protocols are now moved to DTModelStorage repo.
* Implemented searching in UICollectionView

## [2.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/2.0.0)

- Added support for custom storage classes
- Current storage classes moved to separate repo(DTModelStorage)
- Complete rewrite of internal architecture

## [1.1.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/1.1.0)

### Features

* Added support for storyboard cell, header and footer prototyping
* Dropped support for creating cells, headers and footers from code

## [1.0.0](https://github.com/DenHeadless/DTCollectionViewManager/releases/tag/1.0.0)

First release of DTCollectionViewManager, woohoo!

#### Features
* Clean mapping system
* Easy API for collection models manipulation
* Foundation types support
* Full iOS 7 support!
