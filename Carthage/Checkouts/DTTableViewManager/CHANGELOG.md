# Change Log

All notable changes to this project will be documented in this file.

# Next

## [6.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.3.0)

### Added

* Anomaly detecting system for various errors in `DTTableViewManager`. Read more about it in [Anomaly Handler Readme section](https://github.com/DenHeadless/DTTableViewManager#anomaly-handler). Anomaly handler system **requires Swift 4.1 and higher**.
* Support for Swift 4.2 in Xcode 10 beta 1.

### Changed

* Calling `startManaging(withDelegate:_)` method is no longer required.

### Breaking

* `viewFactoryErrorHandler` deprecated property on `DTTableViewManager` was removed. All previously reported errors and warnings are now a part of anomaly detecting system.

## [6.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.2.0)

* `editingStyle(for:_,_:)` method was replaced with `editingStyle(forItem:_,:_)` method, that accepts model and indexPath closure, without cell. Reason for that is that `UITableView` may call this method when cell is not actually on screen, in which case this event would not fire, and current editingStyle of the cell would be lost.

## [6.1.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.1.1)

* Updates for Xcode 9.3 and Swift 4.1

## [6.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.1.0)

## [6.1.0-beta.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.1.0-beta.1)

* Implemented new system for deferring datasource updates until `performBatchUpdates` block. This system is intended to fight crash, that might happen when `performBatchUpdates` method is called after `UITableView.reloadData` method(for example after calling `memoryStorage.setItems`, and then immediately `memoryStorage.addItems`). This issue is detailed in https://github.com/DenHeadless/DTCollectionViewManager/issues/27 and https://github.com/DenHeadless/DTCollectionViewManager/issues/23. This crash can also happen, if iOS 11 API `UITableView.performBatchUpdates` is used. This system is turned on by default. If, for some reason, you want to disable it and have old behavior, call:

```swift
manager.memoryStorage.defersDatasourceUpdates = false
```

* `TableViewUpdater` now uses iOS 11 `performBatchUpdates` API, if this API is available. This API will work properly on `MemoryStorage` only if `defersDatasourceUpdates` is set to `true` - which is default. However, if for some reason you need to use legacy methods `beginUpdates`, `endUpdates`, you can enable them like so:

```swift
manager.tableViewUpdater?.usesLegacyTableViewUpdateMethods = true
```

Please note, though, that new default behavior is recommended, because it is more stable and works the same on both UITableView and UICollectionView.

* `tableViewUpdater` property on `DTTableViewManager` is now of `TableViewUpdater` type instead of opaque `StorageUpdating` type. This should ease use of this object and prevent type unneccessary type casts.

## [6.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.0.0)

* Updated to Xcode 9.1 / Swift 4.0.2

## [6.0.0-beta.3](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.0.0-beta.3)

* Makes `DTTableViewManager` property weak instead of unowned to prevent iOS 10-specific memory issues/crashes.

## [6.0.0-beta.2](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.0.0-beta.2)

* Build with Xcode 9.0 final release.
* Fixed partial-availability warnings.

## [6.0.0-beta.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/6.0.0-beta.1)

**This is a major release with some breaking changes, please read [DTTableViewManager 6.0 Migration Guide](https://github.com/DenHeadless/DTTableViewManager/blob/master/Documentation/DTTableViewManager%206.0%20Migration%20Guide.md)**

* Added `updateVisibleCells(_:) method`, that allows updating cell data for visible cells with callback on each cell. This is more efficient than calling `reloadData` when number of elements in `UITableView` does not change, and only contents of items change.
* Implement `configureEvents(for:_:)` method, that allows batching in several cell events to avoid using T.ModelType for events, that do not have cell created.
* Added event for `UITableViewDelegate` `tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:`
* Added events for focus engine on iOS 9
* Added events for iOS 11 `UITableViewDelegate` methods: `tableView(_:leadingSwipeActionsConfigurationForRowAt:`, `tableView(_:trailingSwipeActionsConfigurationForRowAt:`, `tableView(_:shouldSpringLoadRowAt:withContext:`
* `UITableViewDelegate` and `UITableViewDatasource` implementations have been refactored from `DTTableViewManager` to `DTTableViewDelegate` and `DTTableViewDataSource` classes.
* `DTTableViewManager` now allows registering mappings for specific sections, or mappings with any custom condition.
* Added `move(_:_:)` method to allow setting up events, reacting to `tableView:moveRowAt:to:` method.

# Breaking

* Signature of `move(_:_:)` method has been changed to make it consistent with other events. Arguments received in closure are now: `(destinationIndexPath: IndexPath, cell: T, model: T.ModelType, sourceIndexPath: IndexPath)`
* `tableView(UITableView, moveRowAt: IndexPath, to: IndexPath)` no longer automatically moves items, if current storage is `MemoryStorage`. Please use `MemoryStorage` convenience method `moveItemWithoutAnimation(from:to:)` to move items manually.

# Deprecated

* Error handling system of `DTTableViewManager` is deprecated and can be removed or replaced in future versions of the framework.

## [5.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.3.0)

Dependency changelog -> [DTModelStorage 5.0.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

* Use new events system from DTModelStorage, that allows events to be properly called for cells, that are created using `ViewModelMappingCustomizing` protocol.

## [5.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.2.0)

### New

* Setting `TableViewUpdater` instance to `tableViewUpdater` property on `DTTableViewManager` now triggers `didUpdateContent` closure on `TableViewUpdater`.
* Added `sectionIndexTitles` event to replace `UITableViewDataSource.sectionIndexTitles(for:)` method.
* Added `sectionForSectionIndexTitle` event to replace `UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at)` method.

### Bugfixes

* All events that return Optional value now accept nil as a valid event result.
* `didDeselect(_:,_:)` method now accepts closure without return type - since `UITableViewDelegate` does not have return type in that method.

## [5.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.1.0)

Dependency changelog -> [DTModelStorage 4.0.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

* `TableViewUpdater` has been rewritten to use new `StorageUpdate` properties that track changes in order of their occurence.
* `TableViewUpdater` `reloadRowClosure` and `DTTableViewManager` `updateCellClosure` now accept indexPath and model instead of just indexPath. This is done because update may happen after insertions and deletions and object that needs to be updated may exist on different indexPath.

## [5.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.0.0)

No changes

## [5.0.0-beta.3](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.0.0-beta.3)

* `DTModelStorage` dependency now requires `Realm 2.0`
* `UITableViewDelegate` `heightForHeaderInSection` and `heightForFooterInSection` are now properly called on the delegate, if it implements it(thanks, @augmentedworks!).

## [5.0.0-beta.2](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.0.0-beta.2)

### Added

* `DTTableViewOptionalManageable` protocol, that is identical to `DTTableViewManageable`, but allows optional `tableView` property instead of implicitly unwrapped one.
* Enabled `RealmStorage` from `DTModelStorage` dependency

## [5.0.0-beta.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/5.0.0-beta.1)

This is a major release, written in Swift 3. Read [Migration guide](Documentation/DTTableViewManager 5.0 migration guide.md) with descriptions of all features and changes.

Dependency changelog -> [DTModelStorage 3.0.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

### Added

* New events system that covers almost all available `UITableViewDelegate` and `UITableViewDataSource` delegate methods.
* New class - `TableViewUpdater`, that is calling all animation methods for `UITableView` when required by underlying storage.
* `updateCellClosure` method on `DTTableViewManager`, that manually updates visible cell instead of calling `tableView.reloadRowsAt(_:)` method.
* `coreDataUpdater` property on `DTTableViewManager`, that creates `TableViewUpdater` object, that follows Apple's guide for updating `UITableView` from `NSFetchedResultsControllerDelegate` events.
* `isManagingTableView` property on `DTTableViewManager`
* `unregisterCellClass(_:)`, `unregisterHeaderClass(_:)`, `unregisterFooterClass(_:)` methods to unregister mappings from `DTTableViewManager` and `UITableView`

### Changed

* Event system is migrated to new `EventReaction` class from `DTModelStorage`
* Swift 3 API Design guidelines have been applied to all public API.
* Section and row animations are now set on `TableViewUpdater` class instead of `TableViewConfiguration`

### Removals

* `itemForVisibleCell`, `itemForCellClass:atIndexPath:`, `itemForHeaderClass:atSectionIndex:`, `itemForFooterClass:atSectionIndex:` were removed - they were not particularly useful and can be replaced with much shorter Swift conditional typecasts.
* `registerCellClass:whenSelected` method
* All events methods with method pointer semantics. Please use block based methods instead.
* `dataBindingBehaviour` property.
* `viewBundle` property on `DTTableViewManager`. Bundle is not determined automatically based on view class.
* `DTTableViewContentUpdatable` protocol. Use `TableViewUpdater` properties instead.

## [4.8.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.8.0)

### Changed

* Support for building in both Swift 2.2 and Swift 2.3
* Now all view registration methods use `NSBundle(forClass:)` constructor, instead of falling back on `DTTableViewManager` `viewBundle` property. This allows having cells from separate bundles or frameworks to be used with single `DTTableViewManager` instance.

## [4.7.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.7.0)

Dependency changelog -> [DTModelStorage 2.6.0 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## [4.6.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.6.0)

Dependency changelog -> [DTModelStorage 2.5 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.

### Changed

* Require Only-App-Extension-Safe API is set to YES in framework targets.

## [4.5.3](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.5.0)

## Fixed

* Fixed a bug, where prototype cell from storyboard could not be created after calling `registerCellClass(_:)` method.

## [4.5.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.5.0)

## Added

* Support for Realm database storage - using `RealmStorage` class.
* Ability to defer data binding until `tableView(_:willDisplayCell:forRowAtIndexPath:)` method is called. This can improve  scrolling perfomance for table view cells.
```swift
    manager.dataBindingBehaviour = .BeforeCellIsDisplayed
```

## Changed

* UIReactions now properly unwrap data models, even for cases when model contains double optional value.

## [4.4.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.4.1)

## Fixed

* Issue with Swift 2.1.1 (XCode 7.2) where storage.delegate was not set during initialization

## [4.4.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.4.0)

Dependency changelog -> [DTModelStorage 2.3 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve mapping system and error reporting.

## Added

* [New mapping system](https://github.com/DenHeadless/DTTableViewManager#data-models) with support for protocols and subclasses
* Mappings can now be [customized](https://github.com/DenHeadless/DTTableViewManager#customizing-mapping-resolution) using `DTViewModelMappingCustomizable` protocol.
* [Custom error handler](https://github.com/DenHeadless/DTTableViewManager#error-reporting) for `DTTableViewFactoryError` errors.

## Changed

* preconditionFailures have been replaced with `DTTableViewFactoryError` ErrorType
* Internal `TableViewReaction` class have been replaced by `UIReaction` class from DTModelStorage.

## [4.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.3.0)

Dependency changelog -> [DTModelStorage 2.2 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

## Changed

* Added support for Apple TV platform (tvOS).

## Fixed

* `registerNiblessFooterClass` method now works correctly.

## Renamed

* `objectForCellClass` category of methods have been removed to read item in their title instead of object.

## Removed

* `TableViewStorageUpdating` protocol and conformance has been removed as unnecessary.

## [4.2.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.2.1)

## Updated

* Improved stability by treating UITableView as optional

## [4.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.2.0)

Dependency changelog -> [DTModelStorage 2.1 and higher](https://github.com/DenHeadless/DTModelStorage/releases)

This release aims to improve storage updates and UI animation with UITableView. To make this happen, `DTModelStorage` classes were rewritten and rearchitectured, using Swift `Set`.

There are some backwards-incompatible changes in this release, however Xcode quick-fix tips should guide you through what needs to be changed.

## Added

 * `registerNiblessHeaderClass` and `registerNiblessFooterClass` methods to  support creating `UITableViewHeaderFooterView`s from code

## Fixed

* Fixed retain cycles in event blocks

## [4.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.1.0)

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

## Breaking changes

`beforeContentUpdate` and `afterContentUpdate` closures were replaced with `DTTableViewContentUpdatable` protocol, that can be adopted by your `DTTableViewManageable` class, for example:

```swift
extension PostsViewController: DTTableViewContentUpdatable {
    func afterContentUpdate() {
        // Do something
    }
}
```

## [4.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/4.0.0)

4.0 is a next major release of `DTTableViewManager`. It was rewritten from scratch in Swift 2 and is not backwards-compatible with previous releases.

Read  [4.0 Migration guide](https://github.com/DenHeadless/DTTableViewManager/wiki/4.0-Migration-guide).

[Blog post](http://digginginswift.com/2015/09/13/dttableviewmanager-4-protocol-oriented-uitableview-management-in-swift/)

### Features

* Improved `ModelTransfer` protocol with associated `ModelType`
* `DTTableViewManager` is now a separate object
* New events system, that allows reacting to cell selection, cell/header/footer configuration and content updates
* Added support for `UITableViewController`, and any other object, that has `UITableView`
* New storage object generic-type getters
* Support for Swift types - classes, structs, enums, tuples.

## [3.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.2.0)

### Bugfixes

* Fixed an issue, where storageDidPerformUpdate method could be called without any updates.

## [3.1.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.1.1)

* Added support for installation using [Carthage](https://github.com/Carthage/Carthage) :beers:

## [3.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.1.0)

### Changes

* Added nullability annotations for XCode 6.3 and Swift 1.2


## [3.0.5](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.5)

## Features

Added removeAllTableItemsAnimated method.

## Bugfixes

Fixed issue, that could lead to wrong table items being removed, when using memory storage  removeItemsAtIndexPaths: method.

## [3.0.2](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.2)

### Changes

* Supported frameworks installation from CocoaPods - requires iOS 8.

## [3.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/3.0.0)

### Features
* Full Swift support, including swift model classes
* Added convenience method to update section items
* Added `DTTableViewControllerEvents` protocol, that allows developer to react to changes in datasource
* Registering header or footer view now automatically changes default header/footer style to DTTableViewSectionStyleView.

### Breaking changes

* `DTSectionModel` methods `headerModel` and `footerModel` were renamed. Use `tableHeaderModel` and `tableFooterModel` instead.
* `DTStorage` protocol was renamed to `DTStorageProtocol`.
* `DTTableViewDataStorage` class was removed, it's methods were merged in `DTMemoryStorage`
* `DTDefaultCellModel` and `DTDefaultHeaderFooterModel` were removed.

## [2.7.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.7.0)

This is a release, that is targeted at improving code readability, and reducing number of classes and protocols inside DTTableViewManager architecture.

### Breaking changes

* `DTTableViewMemoryStorage` class was removed. It's methods were transferred to `DTMemoryStorage+DTTableViewManagerAdditions` category.
* `DTTableViewStorageUpdating` protocol was removed. It's methods were moved to `DTTableViewController`.

### Features

* When using `DTCoreDataStorage`, section titles are displayed by default, if NSFetchedController was created with sectionNameKeyPath property.

## [2.5.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.5.0)

### Changes

Preliminary support for Swift.

If you use cells, headers or footers inside storyboards from Swift, implement optional reuseIdentifier method to return real Swift class name instead of the mangled one. This name should also be set as reuseIdentifier in storyboard.

## [2.4.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.4.0)

### Breaking changes

Reuse identifier now needs to be identical to cell, header or footer class names. For example, UserTableCell should now have "UserTableCell" reuse identifier.

## [2.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.3.0)

#### Features

Added properties of `DTTableViewController` to control, whether section headers and footers should be shown for sections, that don't contain any items.

#### Deprecations

Removed `DTModelSearching` protocol, please use `DTMemoryStorage` `setSearchingBlock:forModelClass:` method instead.

## [2.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.2.0)

* `DTModelSearching` protocol is deprecated and is replaced by memoryStorage method setSearchingBlock:forModelClass:
* UITableViewDelegate and UITableViewDatasource properties for UITableView are now filled automatically.
* Added more assertions, programmer errors should be easily captured.

## [2.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.1.0)

#### Breaking changes

Storage classes now use external dependency from [DTModelStorage repo](https://github.com/DenHeadless/DTModelStorage).

Some method calls on memory storage have been renamed, dropping 'table' part from the name, for example
```objective-c
-(void)addTableItems:(NSArray *)items
```
now becomes

```objective-c
-(void)addItems:(NSArray *)items
```

Several protocols and classes have been also renamed:

`DTTableViewModelTransfer` - `DTModelTransfer`
`DTTableViewModelSearching` - `DTModelSearching`
`DTTableViewCoreDataStorage` - `DTCoreDataStorage`

#### Features

Added support for default UITableViewCellStyles and default UITableViewHeaderFooterViews without subclassing.

## [2.0.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/2.0.0)

DTTableViewManager 2.0 is a major update to the framework with several API - breaking changes. Please read [DTTableViewManager 2.0 transition guide for an overview](https://github.com/DenHeadless/DTTableViewManager/wiki/DTTableViewManager-2.0-Transition-Guide).

## [1.3.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.3.0)

#### Features

Added support for storyboard prototype cells.

##### Enhancements

DTTableViewManager renamed to DTTableViewController.

#### Bugfixes

Fixed bug, which prevented using correct height values on custom headers and footers.

## [1.2.1](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.2.1)

#### Features
Added ability to disable logging

##### Enhancements

Improved structure of mapping code, now mapping and cell creation happens completely in DTCellFactory class.

## [1.2.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.2.0)

#### Features

Introducing support for Foundation data models. Cell, header and footer mapping now supports following classes:
* NSString / NSMutableString
* NSNumber
* NSDictionary / NSMutableDictionary
* NSArray / NSMutableArray

#### Deprecations

* option to not reuse cells is removed. Currently there's no obvious reason to not have cell reuse.

## [1.1.0](https://github.com/DenHeadless/DTTableViewManager/releases/tag/1.1.0)

#### Features
Powerful and easy search within UITableView.

#### General changes
Tests are now running on [Travis-CI](https://travis-ci.org/DenHeadless/DTTableViewManager)

#### Deprecations

Ability to create DTTableViewManager as a separate object was removed. If you need to subclass from different UIViewController, consider using iOS Containment API.
