//
//  RealmStorage.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 13.12.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
#if canImport(RealmSwift)
import Realm.RLMResults
import RealmSwift
#else
//swiftlint:disable:next line_length
let error = "RealmSwift framework is needed for RealmStorage to work, which is currently not included in DTModelStorage repo. In order to compile RealmStorage target, please add RealmSwift framework manually. If you need RealmStorage to be included in your app using CocoaPods, use DTModelStorage/Realm subspec."
#endif

/// Storage class, that handles multiple `RealmSection` instances with Realm.Results<T>. It is similar with CoreDataStorage, but for Realm database. 
/// When created, it automatically subscribes for Realm notifications and notifies delegate when it's sections change.
open class RealmStorage: BaseStorage, Storage, SupplementaryStorage, SectionLocationIdentifyable, HeaderFooterSettable
{
    /// Array of `RealmSection` objects
    open var sections = [Section]() {
        didSet {
            sections.forEach {
                ($0 as? SupplementaryAccessible)?.sectionLocationDelegate = self
            }
        }
    }
    
    /// Returns index of `section` or nil, if section is now found
    open func sectionIndex(for section: Section) -> Int? {
        return sections.index(where: {
            return ($0 as AnyObject) === (section as AnyObject)
        })
    }
    
    /// Storage for notification tokens of `Realm`
    private var notificationTokens: [Int:RealmSwift.NotificationToken] = [:]
    
    deinit {
        notificationTokens.values.forEach { token in
            token.invalidate()
        }
    }
    
    /// Returns section at `sectionIndex` or nil, if it does not exist
    ///
    /// - Returns: `RealmSection` instance
    open func section(at sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        
        return sections[sectionIndex]
    }
    
    /// Adds `RealmSection`, containing `results`.
    open func addSection<T:RealmCollection>(with results: T) {
        setSection(with: results, forSection: sections.count)
    }
    
    /// Sets `RealmSection`, containing `results` objects, for section at `index`. 
    ///
    ///  Calls `delegate.storageNeedsReloading()` after section is set. Subscribes for Realm notifications to automatically update section when update occurs.
    /// - Note: if index is less than number of section, this method won't do anything.
    open func setSection<T:RealmCollection>(with results: T, forSection index: Int) {
        guard index <= sections.count else { return }
        
        let section = RealmSection(results: AnyRealmCollection(results))
        notificationTokens[index]?.invalidate()
        notificationTokens[index] = nil
        if index == sections.count {
            sections.append(section)
        } else {
            sections[index] = section
        }
        if results.realm?.configuration.readOnly == false {
            let sectionIndex = sections.count - 1
            notificationTokens[index] = results.observe({ [weak self] change in
                self?.handleChange(change, inSection: sectionIndex)
                })
        }
        delegate?.storageNeedsReloading()
    }
    
    /// Handles `change` in `section`, automatically notifying delegate.
    final func handleChange<T>(_ change: RealmCollectionChange<T>, inSection: Int)
    {
        if case RealmCollectionChange.initial(_) = change {
            delegate?.storageNeedsReloading()
            return
        }
        guard case let RealmCollectionChange.update(_, deletions, insertions, modifications) = change else {
            return
        }
        startUpdate()
        deletions.forEach{ [weak self] in
            self?.currentUpdate?.objectChanges.append((.delete, [IndexPath(item: $0, section: inSection)]))
        }
        insertions.forEach{ [weak self] in
            self?.currentUpdate?.objectChanges.append((.insert, [IndexPath(item: $0, section: inSection)]))
        }
        modifications.forEach{ [weak self] in
            self?.currentUpdate?.objectChanges.append((.update, [IndexPath(item: $0, section: inSection)]))
            self?.currentUpdate?.updatedObjects[IndexPath(item: $0, section: inSection)] = self?.item(at: IndexPath(item: $0, section: inSection))
        }
        finishUpdate()
    }
    
    /// Delete sections at `indexes`. 
    ///
    /// Delegate will be automatically notified of changes.
    open func deleteSections(_ indexes: IndexSet) {
        startUpdate()
        defer { self.finishUpdate() }
        
        var markedForDeletion = [Int]()
        for section in indexes where section < self.sections.count {
            markedForDeletion.append(section)
        }
        for section in markedForDeletion.sorted().reversed() {
            notificationTokens[section]?.invalidate()
            notificationTokens[section] = nil
            self.sections.remove(at: section)
        }
        markedForDeletion.forEach {
            currentUpdate?.sectionChanges.append((.delete, [$0]))
        }
    }
    
    /// Sets section header `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionHeaderModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        guard let headerKind = supplementaryHeaderKind else {
            assertionFailure("supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method"); return
        }
        let section = (self.section(at: sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: headerKind, atIndex: 0)
    }
    
    /// Sets section footer `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionFooterModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        guard let footerKind = supplementaryFooterKind else {
            assertionFailure("supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method"); return
        }
        let section = (self.section(at: sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: footerKind, atIndex: 0)
    }
    
    /// Sets supplementary `models` for supplementary of `kind`.
    ///
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    open func setSupplementaries(_ models: [[Int: Any]], forKind kind: String)
    {
        if models.count == 0 {
            for index in 0 ..< self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessible
                section?.supplementaries[kind] = nil
            }
            return
        }
        
        assert(sections.count >= models.count, "The section should be set before setting supplementaries")
        
        for index in 0 ..< models.count {
            let section = self.sections[index] as? SupplementaryAccessible
            section?.supplementaries[kind] = models[index]
        }
    }
        
    // MARK: - Storage
    
    /// Returns item at `indexPath` or nil, if it is not found.
    open func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.section < sections.count else {
            return nil
        }
        guard indexPath.item < sections[indexPath.section].items.count else { return nil }
        return sections[indexPath.section].items[indexPath.item]
    }
    
    // MARK: - SupplementaryStorage
    
    /// Returns supplementary model of supplementary `kind` for section at `sectionIndexPath`. Returns nil if not found.
    ///
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModel(ofKind kind: String, forSectionAt sectionIndexPath: IndexPath) -> Any? {
        guard sectionIndexPath.section < sections.count else { return nil }
        
        return (sections[sectionIndexPath.section] as? SupplementaryAccessible)?.supplementaryModel(ofKind:kind, atIndex: sectionIndexPath.item)
    }
}
