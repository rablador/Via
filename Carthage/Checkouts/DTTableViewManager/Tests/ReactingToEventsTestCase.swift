//
//  ReactingToEventsTestCase.swift
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 19.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
@testable import DTTableViewManager
import Nimble

extension DTTableViewManager {
    var usesLegacyUpdateAPI : Bool {
        if #available(iOS 11, tvOS 11, *) {
            return tableViewUpdater?.usesLegacyTableViewUpdateMethods ?? false
        }
        return true
    }
}

#if os(iOS) && swift(>=3.2)
    
@available (iOS 11, *)
class SpringLoadedContextMock : NSObject, UISpringLoadedInteractionContext {
    var state: UISpringLoadedInteractionEffectState = .activated
    
    var targetView: UIView?
    var targetItem: Any?
    func location(in view: UIView?) -> CGPoint {
        return .zero
    }
}
    
@available (iOS 11, *)
class DragAndDropMock : NSObject, UIDragSession, UIDropSession {
    var progress: Progress = Progress()
    
    var localDragSession: UIDragSession?
    
    var progressIndicatorStyle: UIDropSessionProgressIndicatorStyle = .default
    
    func canLoadObjects(ofClass aClass: NSItemProviderReading.Type) -> Bool {
        return false
    }
    
    func loadObjects(ofClass aClass: NSItemProviderReading.Type, completion: @escaping ([NSItemProviderReading]) -> Void) -> Progress {
        return Progress()
    }
    
    var items: [UIDragItem] = []
    
    func location(in view: UIView) -> CGPoint {
        return CGPoint()
    }
    
    var allowsMoveOperation: Bool = true
    
    var isRestrictedToDraggingApplication: Bool = false
    
    func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [String]) -> Bool {
        return false
    }
    
    var localContext: Any?
}
    
@available (iOS 11, *)
class DropPlaceholderContextMock : NSObject, UITableViewDropPlaceholderContext {
    var dragItem: UIDragItem = UIDragItem(itemProvider: NSItemProvider(contentsOf: URL(fileURLWithPath: ""))!)
    func commitInsertion(dataSourceUpdates: (IndexPath) -> Void) -> Bool {
        return true
    }
    
    func deletePlaceholder() -> Bool {
        return true
    }
    
    func addAnimations(_ animations: @escaping () -> Void) {
        
    }
    
    func addCompletion(_ completion: @escaping (UIViewAnimatingPosition) -> Void) {
        
    }
}
    
@available (iOS 11, *)
class DropCoordinatorMock: NSObject, UITableViewDropCoordinator {
    var items: [UITableViewDropItem] = []
    
    var destinationIndexPath: IndexPath?
    
    var proposal: UITableViewDropProposal = .init(operation: .copy, intent: .automatic)
    
    var session: UIDropSession = DragAndDropMock()
    
    override init() {
        super.init()
    }
    
    func drop(_ dragItem: UIDragItem, to placeholder: UITableViewDropPlaceholder) -> UITableViewDropPlaceholderContext {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, toRowAt indexPath: IndexPath) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, intoRowAt indexPath: IndexPath, rect: CGRect) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
    
    func drop(_ dragItem: UIDragItem, to target: UIDragPreviewTarget) -> UIDragAnimating {
        return DropPlaceholderContextMock()
    }
        
    
}
    
#endif

class AlwaysVisibleTableView: UITableView
{
    override func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return self.dataSource?.tableView(self, cellForRowAt: indexPath)
    }
    
    
    override func headerView(forSection section: Int) -> UITableViewHeaderFooterView? {
        return self.delegate?.tableView!(self, viewForHeaderInSection: section) as? UITableViewHeaderFooterView
    }
}

class ReactingTestTableViewController: DTTestTableViewController
{
    var indexPath : IndexPath?
    var model: Int?
    var text : String?
}

class ViewModelMappingCustomizingController : ReactingTestTableViewController, ViewModelMappingCustomizing {
    var viewModelMappingCustomization : ([ViewModelMapping], Any) -> ViewModelMapping = { mappings, _ in
        return mappings.first!
    }
    
    func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        return viewModelMappingCustomization(candidates, model)
    }
}

fileprivate class FirstTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

fileprivate class SecondTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class ViewModelMappingCustomizationTestCase : XCTestCase {
    var sut : ViewModelMappingCustomizingController!
    
    override func setUp() {
        super.setUp()
        sut = ViewModelMappingCustomizingController()
        sut.tableView = AlwaysVisibleTableView()
        _ = sut.view
    }
    
    func testEventReactionsSupportViewModelMappingCustomization() {
        sut.manager.memoryStorage.defersDatasourceUpdates = true
        sut.manager.register(FirstTableViewCell.self)
        sut.manager.register(SecondTableViewCell.self)
        
        sut.viewModelMappingCustomization = { mappings,_ in return mappings.last! }
        sut.manager.didSelect(FirstTableViewCell.self) { cell, _, _ in
            XCTFail()
        }
        let exp = expectation(description: "did select second cell")
        sut.manager.didSelect(SecondTableViewCell.self) { cell, _, _ in
            exp.fulfill()
        }
        
        sut.manager.memoryStorage.addItems([1,2], toSection: 0)
        sut.manager.tableDelegate?.tableView(sut.tableView, didSelectRowAt: indexPath(0, 0))
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}

class ReactingToEventsTestCase: XCTestCase {

    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.memoryStorage.defersDatasourceUpdates = true
    }
    
    func testCellSelectionClosure()
    {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        controller.manager.register(SelectionReactingTableCell.self)
        var reactingCell : SelectionReactingTableCell?
        controller.manager.didSelect(SelectionReactingTableCell.self) { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            reactingCell = cell
        }
        
        controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        controller.manager.tableDelegate?.tableView(controller.tableView, didSelectRowAt: indexPath(1, 0))
        
        expect(reactingCell?.indexPath) == indexPath(1, 0)
        expect(reactingCell?.model) == 2
    }
    
    func testCellSelectionPerfomance() {
        if #available(iOS 11, tvOS 11, *) {
            controller.tableView = UITableView()
        }
        controller.manager.register(SelectionReactingTableCell.self)
        self.controller.manager.memoryStorage.addItems([1,2], toSection: 0)
        #if swift(>=4.0)
            measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: true) {
            self.controller.manager.didSelect(SelectionReactingTableCell.self) { (_, _, _) in
                self.stopMeasuring()
            }
            self.controller.manager.tableDelegate?.tableView(self.controller.tableView, didSelectRowAt: indexPath(1, 0))
            }
        #else
            measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: true) {
                self.controller.manager.didSelect(SelectionReactingTableCell.self) { (_, _, _) in
                    self.stopMeasuring()
                }
                self.controller.manager.tableDelegate?.tableView(self.controller.tableView, didSelectRowAt: indexPath(1, 0))
            }
        #endif
    }
    
    func testCellConfigurationClosure()
    {
        controller.manager.register(SelectionReactingTableCell.self)
        
        var reactingCell : SelectionReactingTableCell?
        
        controller.manager.configure(SelectionReactingTableCell.self, { (cell, model, indexPath) in
            cell.indexPath = indexPath
            cell.model = model
            cell.textLabel?.text = "Foo"
            reactingCell = cell
        })
        
        controller.manager.memoryStorage.addItem(2, toSection: 0)
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, cellForRowAt: indexPath(0, 0))
        
        expect(reactingCell?.indexPath) == indexPath(0, 0)
        expect(reactingCell?.model) == 2
        expect(reactingCell?.textLabel?.text) == "Foo"
    }
    
    func testHeaderConfigurationClosure()
    {
        controller.manager.registerHeader(ReactingHeaderFooterView.self)
        
        var reactingHeader : ReactingHeaderFooterView?
        
        controller.manager.configureHeader(ReactingHeaderFooterView.self) { (header, model, sectionIndex) in
            header.model = "Bar"
            header.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        reactingHeader = controller.manager.tableDelegate?.tableView(controller.tableView, viewForHeaderInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingHeader?.sectionIndex) == 0
        expect(reactingHeader?.model) == "Bar"
    }
    
    func testFooterConfigurationClosure()
    {
        controller.manager.registerFooter(ReactingHeaderFooterView.self)
        
        var reactingFooter : ReactingHeaderFooterView?
        
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { (footer, model, sectionIndex) in
            footer.model = "Bar"
            footer.sectionIndex = sectionIndex
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        reactingFooter = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0) as? ReactingHeaderFooterView
        
        expect(reactingFooter?.sectionIndex) == 0
        expect(reactingFooter?.model) == "Bar"
    }
    
    func testShouldReactAfterContentUpdate()
    {
        controller.manager.register(NibCell.self)
        let exp = expectation(description: "didUpdateContent")
        controller.manager.tableViewUpdater?.didUpdateContent = { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldReactBeforeContentUpdate()
    {
        controller.manager.register(NibCell.self)
        let exp = expectation(description: "willUpdateContent")
        controller.manager.tableViewUpdater?.willUpdateContent = { _ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.addItem(1, toSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

class ReactingToEventsFastTestCase : XCTestCase {
    var controller : ReactingTestTableViewController!
    
    override func setUp() {
        super.setUp()
        controller = ReactingTestTableViewController()
        controller.tableView = AlwaysVisibleTableView()
        let _ = controller.view
        controller.manager.registerFooter(ReactingHeaderFooterView.self)
        controller.manager.register(NibCell.self)
        controller.manager.memoryStorage.defersDatasourceUpdates = true
    }
    
    func testFooterConfigurationClosure()
    {
        let exp = expectation(description: "Configure footer")
        controller.manager.configureFooter(ReactingHeaderFooterView.self) { _,_,_ in
            exp.fulfill()
        }
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, viewForFooterInSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "heightForRowAtIndexPath")
        if !controller.manager.usesLegacyUpdateAPI {
            #if os(iOS)
                exp.expectedFulfillmentCount = 4
            #endif
        }
        controller.manager.heightForCell(withItem: Int.self, { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        if controller.manager.usesLegacyUpdateAPI {
            _ = controller.manager.tableDelegate?.tableView(controller.tableView, heightForRowAt: indexPath(0, 0))
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "estimatedHeightForRowAtIndexPath")
        if !controller.manager.usesLegacyUpdateAPI {
            exp.expectedFulfillmentCount = 2
        }
        controller.manager.estimatedHeightForCell(withItem: Int.self, { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, estimatedHeightForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testIndentationLevelForRowAtIndexPathClosure()
    {
        let exp = expectation(description: "indentationLevelForRowAtIndexPath")
        if !controller.manager.usesLegacyUpdateAPI {
            #if os(iOS)
                exp.expectedFulfillmentCount = 2
            #endif
        }
        controller.manager.indentationLevelForCell(withItem: Int.self, { int, indexPath in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, indentationLevelForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillSelectRowAtIndexPathClosure() {
        let exp = expectation(description: "willSelect")
        controller.manager.willSelect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willSelectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "willDeselect")
        controller.manager.willDeselect(NibCell.self, { (cell, model, indexPath) -> IndexPath? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidDeselectRowAtIndexPathClosure() {
        let exp = expectation(description: "didDeselect")
        controller.manager.didDeselect(NibCell.self, { cell, model, indexPath in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didDeselectRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayRowAtIndexPathClosure() {
        let exp = expectation(description: "willDisplay")
        if !controller.manager.usesLegacyUpdateAPI {
            #if os(iOS)
                exp.expectedFulfillmentCount = 2
            #endif
        }
        controller.manager.willDisplay(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDisplay: NibCell(), forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testEditActionsForRowAtIndexPathClosure() {
        let exp = expectation(description: "editActions")
        controller.manager.editActions(for: NibCell.self, { (cell, model, indexPath) -> [UITableViewRowAction]? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, editActionsForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testAccessoryButtonTappedForRowAtIndexPathClosure() {
        let exp = expectation(description: "accessoryButtonTapped")
        controller.manager.accessoryButtonTapped(in: NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, accessoryButtonTappedForRowWith: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCommitEditingStyleForRowAtIndexPathClosure() {
        let exp = expectation(description: "commitEditingStyle")
        controller.manager.commitEditingStyle(for: NibCell.self, { style, cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, commit: .delete, forRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanEditRowAtIndexPathClosure() {
        let exp = expectation(description: "canEditRow")
        controller.manager.canEditCell(withItem: Int.self, { (model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        if controller.manager.usesLegacyUpdateAPI {
            _ = controller.manager.tableDataSource?.tableView(controller.tableView, canEditRowAt: indexPath(0,0))
        }
        #if os(tvOS)
            if #available(tvOS 11, *) {
                _ = controller.manager.tableDataSource?.tableView(controller.tableView, canEditRowAt: indexPath(0,0))
            }
        #endif
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanMoveRowAtIndexPathClosure() {
        let exp = expectation(description: "canMoveRow")
        controller.manager.canMove(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return false
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, canMoveRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForHeaderInSection() {
        let exp = expectation(description: "heightForHeader")
        exp.expectedFulfillmentCount = 2
        controller.manager.heightForHeader(withItem: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        controller.tableView.beginUpdates()
        controller.tableView.endUpdates()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForHeaderInSection() {
        let exp = expectation(description: "estimatedHeightForHeader")
        #if os(iOS)
            exp.expectedFulfillmentCount = 2
        #endif
        #if os(tvOS)
            if #available(tvOS 11, *) {
                
            } else {
               exp.expectedFulfillmentCount = 2
            }
        #endif
        
        controller.manager.estimatedHeightForHeader(withItem: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        if #available(iOS 11, tvOS 11, *) {
            
        } else {
            controller.tableView.beginUpdates()
            controller.tableView.endUpdates()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testHeightForFooterInSection() {
        let exp = expectation(description: "heightForHeader")
        exp.expectedFulfillmentCount = 2
        controller.manager.heightForFooter(withItem: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        controller.tableView.beginUpdates()
        controller.tableView.endUpdates()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEstimatedHeightForFooterInSection() {
        let exp = expectation(description: "estimatedHeightForFooter")
        controller.manager.estimatedHeightForFooter(withItem: String.self, { (model, section) -> CGFloat in
            exp.fulfill()
            return 0
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayHeaderInSection() {
        let exp = expectation(description: "willDisplayHeaderInSection")
        controller.manager.willDisplayHeaderView(ReactingHeaderFooterView.self, { header, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDisplayHeaderView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWillDisplayFooterInSection() {
        let exp = expectation(description: "willDisplayFooterInSection")
        controller.manager.willDisplayFooterView(ReactingHeaderFooterView.self, { footer, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willDisplayFooterView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testWillBeginEditingRowAtIndexPathClosure() {
        let exp = expectation(description: "willBeginEditing")
        controller.manager.willBeginEditing(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, willBeginEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndEditingRowAtIndexPathClosure() {
        let exp = expectation(description: "didEndEditing")
        controller.manager.didEndEditing(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didEndEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testEditingStyleForRowAtIndexPath() {
        let exp = expectation(description: "editingStyle")
        controller.manager.editingStyle(forItem: Int.self, { model, indexPath in
            exp.fulfill()
            return .none
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, editingStyleForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS)
    func testTitleForDeleteButtonForRowAtIndexPath() {
        let exp = expectation(description: "titleForDeleteButton")
        controller.manager.titleForDeleteConfirmationButton(in: NibCell.self, { (cell, model, indexPath) -> String? in
            exp.fulfill()
            return nil
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, titleForDeleteConfirmationButtonForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif
    
    func testShouldIndentRowWhileEditingAtIndexPath() {
        let exp = expectation(description: "shouldIndent")
        controller.manager.shouldIndentWhileEditing(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, shouldIndentWhileEditingRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingRowAtIndexPathClosure() {
        let exp = expectation(description: "didEndDispaying")
        controller.manager.didEndDisplaying(NibCell.self, { cell, model, indexPath  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didEndDisplaying:NibCell(), forRowAt : indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingHeaderInSection() {
        let exp = expectation(description: "didEndDisplayingHeaderInSection")
        controller.manager.didEndDisplayingHeaderView(ReactingHeaderFooterView.self, { header, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionHeaderModels(["Foo"])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didEndDisplayingHeaderView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidEndDisplayingFooterInSection() {
        let exp = expectation(description: "didEndDisplayingFooterInSection")
        controller.manager.didEndDisplayingFooterView(ReactingHeaderFooterView.self, { footer, model, section  in
            exp.fulfill()
        })
        controller.manager.memoryStorage.setSectionFooterModels(["Foo"])
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didEndDisplayingFooterView: ReactingHeaderFooterView(), forSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldMenuForRowAtIndexPath() {
        let exp = expectation(description: "shouldShowMenu")
        controller.manager.shouldShowMenu(for: NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, shouldShowMenuForRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "canPerformActionForRowAtIndexPath")
        controller.manager.canPerformAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, canPerformAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerformActionForRowAtIndexPath() {
        let exp = expectation(description: "performActionForRowAtIndexPath")
        controller.manager.performAction(for: NibCell.self, { (selector, sender, cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, performAction: #selector(testDidEndDisplayingFooterInSection), forRowAt: indexPath(0, 0), withSender: exp)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldHighlightRowAtIndexPath() {
        let exp = expectation(description: "shouldHighlight")
        controller.manager.shouldHighlight(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, shouldHighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidHighlightRowAtIndexPath() {
        let exp = expectation(description: "didHighlight")
        controller.manager.didHighlight(NibCell.self, { (cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didHighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDidUnhighlightRowAtIndexPath() {
        let exp = expectation(description: "didUnhighlight")
        controller.manager.didUnhighlight(NibCell.self, { (cell, model, indexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, didUnhighlightRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available(iOS 9.0, tvOS 9.0, *)
    func testCanFocusRowAtIndexPath() {
        let exp = expectation(description: "canFocus")
        controller.manager.canFocus(NibCell.self, { (cell, model, indexPath) -> Bool in
            exp.fulfill()
            return true
        })
        controller.manager.memoryStorage.addItem(3)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, canFocusRowAt: indexPath(0,0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    #if os(iOS)
    func testSectionIndexTitlesFor() {
        let exp = expectation(description: "sectionIndexTitles")
        controller.manager.sectionIndexTitles {
            exp.fulfill()
            return ["1","2"]
        }
        _ = controller.manager.tableDataSource?.sectionIndexTitles(for: controller.tableView)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testSectionForSectionIndexTitleAt() {
        let exp = expectation(description: "sectionForSectionIndexTitle")
        controller.manager.sectionForSectionIndexTitle { title, index -> Int in
            exp.fulfill()
            return 5
        }
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, sectionForSectionIndexTitle: "2", at: 3)
        waitForExpectations(timeout: 0.5, handler: nil)
    }
    #endif
    
    func testMoveRowAtIndexPath() {
        controller.manager.memoryStorage.defersDatasourceUpdates = true
        let exp = expectation(description: "Move row at indexPath")
        controller.manager.move(NibCell.self, { (cell, model, sourceIndexPath, destinationIndexPath) in
            exp.fulfill()
            return
        })
        controller.manager.memoryStorage.addItems([3,4])
        _ = controller.manager.tableDataSource?.tableView(controller.tableView, moveRowAt: indexPath(0,0), to: indexPath(1, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #if os(iOS) && swift(>=3.2)
    func testItemsForBeginningInDragSession() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "ItemsForBeginningInDragSession")
        controller.manager.itemsForBeginningDragSession(from: NibCell.self) { session, cell, model, _ in
            exp.fulfill()
            return []
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, itemsForBeginning: DragAndDropMock(), at: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testItemsForAddingToDragSession() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "ItemsForAddingToDragSession")
        controller.manager.itemsForAddingToDragSession(from: NibCell.self) { session, point, cell, model, _ in
            exp.fulfill()
            return []
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, itemsForAddingTo: DragAndDropMock(), at: indexPath(0,0), point: .zero)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragPreviewParametersForRowAtIndexPath() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dragPreviewParametersForRowAtIndexPath")
        controller.manager.dragPreviewParameters(for: NibCell.self) { cell, model, indexPath in
            exp.fulfill()
            return nil
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, dragPreviewParametersForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionWillBegin() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dragSessionWillBegin")
        controller.manager.dragSessionWillBegin { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, dragSessionWillBegin: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionDidEnd() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dragSessionDidEnd")
        controller.manager.dragSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, dragSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionAllowsMoveOperation() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dragSessionAllowsMoveOperation")
        controller.manager.dragSessionAllowsMoveOperation{ _  in
            exp.fulfill()
            return true
        }
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, dragSessionAllowsMoveOperation: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDragSessionIsRestrictedToDraggingApplication() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dragSessionRestrictedToDraggingApplication")
        controller.manager.dragSessionIsRestrictedToDraggingApplication{ _  in
            exp.fulfill()
            return true
        }
        _ = controller.manager.tableDragDelegate?.tableView(controller.tableView, dragSessionIsRestrictedToDraggingApplication: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// MARK: - UITableViewDropDelegate
    
    func testPerformDropWithCoordinator() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "performDropWithCoordinator")
        controller.manager.performDropWithCoordinator { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, performDropWith: DropCoordinatorMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCanHandleDropSession() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "canHandleDropSession")
        controller.manager.canHandleDropSession { _ in
            exp.fulfill()
            return true
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, canHandle: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnter() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dropSessionDidEnter")
        controller.manager.dropSessionDidEnter { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, dropSessionDidEnter: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidUpdate() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dropSessionDidUpdate")
        controller.manager.dropSessionDidUpdate { _, _ in
            exp.fulfill()
            return UITableViewDropProposal(operation: .cancel)
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, dropSessionDidUpdate: DragAndDropMock(), withDestinationIndexPath: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidExit() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dropSessionDidExit")
        controller.manager.dropSessionDidExit { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, dropSessionDidExit: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropSessionDidEnd() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dropSessionDidEnd")
        controller.manager.dropSessionDidEnd { _ in
            exp.fulfill()
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, dropSessionDidEnd: DragAndDropMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDropPreviewParametersForRowAtIndexPath() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "dropPreviewParametersForRowAtIndexPath")
        controller.manager.dropPreviewParameters { _ in
            exp.fulfill()
            return nil
        }
        _ = controller.manager.tableDropDelegate?.tableView(controller.tableView, dropPreviewParametersForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLeadingSwipeActionsConfiguration() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "leadingSwipeActionsConfiguration")
        controller.manager.leadingSwipeActionsConfiguration(for: NibCell.self) { _, _, _ in
            exp.fulfill()
            return nil
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, leadingSwipeActionsConfigurationForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testTrailingSwipeActionsConfiguration() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "trailingSwipeActionsConfiguration")
        controller.manager.trailingSwipeActionsConfiguration(for: NibCell.self) { _, _, _ in
            exp.fulfill()
            return nil
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldSpringLoadRow() {
        guard #available(iOS 11, *) else { return }
        let exp = expectation(description: "shouldSpringLoadRow")
        controller.manager.shouldSpringLoad(NibCell.self) { _,_,_,_ in
            exp.fulfill()
            return false
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView, shouldSpringLoadRowAt: indexPath(0, 0), with: SpringLoadedContextMock())
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    #endif
    
    func testTargetIndexPathForMoveFromTo() {
        let exp = expectation(description: "targetIndexPathForMoveFromRowToRow")
        controller.manager.targetIndexPathForMove(NibCell.self) { _, _, _, _ in
            exp.fulfill()
            return indexPath(0, 0)
        }
        controller.manager.memoryStorage.addItem(1)
        _ = controller.manager.tableDelegate?.tableView(controller.tableView,
                                                        targetIndexPathForMoveFromRowAt: indexPath(0, 0),
                                                        toProposedIndexPath: indexPath(1, 0))
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    @available (iOS 9, *)
    func testIndexPathForPreferredFocusedView() {
        let exp = expectation(description: "indexPathForPreferredFocusedView")
        controller.manager.indexPathForPreferredFocusedView {
            exp.fulfill()
            return nil
        }
        _ = controller.manager.tableDelegate?.indexPathForPreferredFocusedView(in: controller.tableView)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAllDelegateMethodSignatures() {
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)))) == EventMethodSignature.commitEditingStyleForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)))) == EventMethodSignature.canEditRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)))) == EventMethodSignature.canMoveRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))) == EventMethodSignature.moveRowAtIndexPathToIndexPath.rawValue
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDataSource.sectionIndexTitles(for:)))) == EventMethodSignature.sectionIndexTitlesForTableView.rawValue
        expect(String(describing: #selector(UITableViewDataSource.tableView(_:sectionForSectionIndexTitle:at:)))) == EventMethodSignature.sectionForSectionIndexTitleAtIndex.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForRowAt:)))) == EventMethodSignature.heightForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForRowAt:)))) == EventMethodSignature.estimatedHeightForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:indentationLevelForRowAt:)))) == EventMethodSignature.indentationLevelForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:)))) == EventMethodSignature.willDisplayCellForRowAtIndexPath.rawValue
        
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:editActionsForRowAt:)))) == EventMethodSignature.editActionsForRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:accessoryButtonTappedForRowWith:)))) == EventMethodSignature.accessoryButtonTappedForRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:)))) == EventMethodSignature.willSelectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))) == EventMethodSignature.didSelectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:)))) == EventMethodSignature.willDeselectRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)))) == EventMethodSignature.didDeselectRowAtIndexPath.rawValue
        
        // These methods are not equal on purpose - DTTableViewManager implements custom logic in them, and they are always implemented, even though they can act as events
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForHeaderInSection:)))) != EventMethodSignature.heightForHeaderInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:heightForFooterInSection:)))) != EventMethodSignature.heightForFooterInSection.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForHeaderInSection:)))) == EventMethodSignature.estimatedHeightForHeaderInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:estimatedHeightForFooterInSection:)))) == EventMethodSignature.estimatedHeightForFooterInSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayHeaderView:forSection:)))) == EventMethodSignature.willDisplayHeaderForSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willDisplayFooterView:forSection:)))) == EventMethodSignature.willDisplayFooterForSection.rawValue
        
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:willBeginEditingRowAt:)))) == EventMethodSignature.willBeginEditingRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndEditingRowAt:)))) == EventMethodSignature.didEndEditingRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:editingStyleForRowAt:)))) == EventMethodSignature.editingStyleForRowAtIndexPath.rawValue
        #if os(iOS)
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:titleForDeleteConfirmationButtonForRowAt:)))) == EventMethodSignature.titleForDeleteButtonForRowAtIndexPath.rawValue
        #endif
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldIndentWhileEditingRowAt:)))) == EventMethodSignature.shouldIndentWhileEditingRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:)))) == EventMethodSignature.didEndDisplayingCellForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingHeaderView:forSection:)))) == EventMethodSignature.didEndDisplayingHeaderViewForSection.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didEndDisplayingFooterView:forSection:)))) == EventMethodSignature.didEndDisplayingFooterViewForSection.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldShowMenuForRowAt:)))) == EventMethodSignature.shouldShowMenuForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:canPerformAction:forRowAt:withSender:)))) == EventMethodSignature.canPerformActionForRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:performAction:forRowAt:withSender:)))) == EventMethodSignature.performActionForRowAtIndexPath.rawValue
        
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldHighlightRowAt:)))) == EventMethodSignature.shouldHighlightRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:)))) == EventMethodSignature.didHighlightRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:didUnhighlightRowAt:)))) == EventMethodSignature.didUnhighlightRowAtIndexPath.rawValue
        expect(String(describing: #selector(UITableViewDelegate.tableView(_:targetIndexPathForMoveFromRowAt:toProposedIndexPath:)))) == EventMethodSignature.targetIndexPathForMoveFromRowAtIndexPath.rawValue
        if #available(iOS 9.0, tvOS 9.0, *) {
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:canFocusRowAt:)))) == EventMethodSignature.canFocusRowAtIndexPath.rawValue
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldUpdateFocusIn:)))) == EventMethodSignature.shouldUpdateFocusInContext.rawValue
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:didUpdateFocusIn:with:)))) == EventMethodSignature.didUpdateFocusInContextWithAnimationCoordinator.rawValue
            expect(String(describing: #selector(UITableViewDelegate.indexPathForPreferredFocusedView(in:)))) == EventMethodSignature.indexPathForPreferredFocusedViewInTableView.rawValue
        }
        
        // MARK: - UITableViewDragDelegate
        #if os(iOS) && swift(>=3.2)
        if #available(iOS 11, *) {
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:itemsForBeginning:at:)))) == EventMethodSignature.itemsForBeginningDragSession.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:itemsForAddingTo:at:point:)))) == EventMethodSignature.itemsForAddingToDragSession.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragPreviewParametersForRowAt:)))) == EventMethodSignature.dragPreviewParametersForRowAtIndexPath.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionWillBegin:)))) == EventMethodSignature.dragSessionWillBegin.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionDidEnd:)))) == EventMethodSignature.dragSessionDidEnd.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionAllowsMoveOperation:)))) == EventMethodSignature.dragSessionAllowsMoveOperation.rawValue
            expect(String(describing: #selector(UITableViewDragDelegate.tableView(_:dragSessionIsRestrictedToDraggingApplication:)))) == EventMethodSignature.dragSessionIsRestrictedToDraggingApplication.rawValue
            
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:performDropWith:)))) == EventMethodSignature.performDropWithCoordinator.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:canHandle:)))) == EventMethodSignature.canHandleDropSession.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidEnter:)))) == EventMethodSignature.dropSessionDidEnter.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidUpdate:withDestinationIndexPath:)))) == EventMethodSignature.dropSessionDidUpdateWithDestinationIndexPath.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidExit:)))) == EventMethodSignature.dropSessionDidExit.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropSessionDidEnd:)))) == EventMethodSignature.dropSessionDidEnd.rawValue
            expect(String(describing: #selector(UITableViewDropDelegate.tableView(_:dropPreviewParametersForRowAt:)))) == EventMethodSignature.dropPreviewParametersForRowAtIndexPath.rawValue
            
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:leadingSwipeActionsConfigurationForRowAt:)))) == EventMethodSignature.leadingSwipeActionsConfigurationForRowAtIndexPath.rawValue
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:trailingSwipeActionsConfigurationForRowAt:)))) == EventMethodSignature.trailingSwipeActionsConfigurationForRowAtIndexPath.rawValue
            expect(String(describing: #selector(UITableViewDelegate.tableView(_:shouldSpringLoadRowAt:with:)))) == EventMethodSignature.shouldSpringLoadRowAtIndexPathWithContext.rawValue
        }
        
        #endif
    }
    
    func testEventsRegistrationPerfomance() {
        let manager = self.controller.manager
        #if swift(>=4.1)
        manager.anomalyHandler.anomalyAction = { _ in }
        #endif
        measure {
            manager.commitEditingStyle(for: NibCell.self, { _,_,_,_ in })
            manager.canEditCell(withItem: Int.self, { _,_ in return true })
            manager.canMove(NibCell.self, { _,_,_ in return true })
            manager.heightForCell(withItem: Int.self, { _,_ in return 44 })
            manager.estimatedHeightForCell(withItem: Int.self, { _,_ in return 44 })
            manager.indentationLevelForCell(withItem: Int.self,  { _,_ in return 0})
            manager.willDisplay(NibCell.self, { _,_,_ in })
            manager.accessoryButtonTapped(in: NibCell.self, { _,_,_ in })
            manager.willSelect(NibCell.self, {_,_,_ in return indexPath(0, 0)})
            manager.didSelect(NibCell.self, {_,_,_ in})
            manager.willDeselect(NibCell.self, {_,_,_ in return indexPath(0, 0)} )
            manager.didDeselect(NibCell.self, { _,_,_ in return })
            manager.heightForHeader(withItem: Int.self, { _,_ in return 20 })
            manager.heightForFooter(withItem: Int.self, { _,_ in return 20 })
            manager.estimatedHeightForHeader(withItem: Int.self, { _,_ in return 20 })
            manager.estimatedHeightForFooter(withItem: Int.self, { _,_ in return 20 })
            manager.willDisplayHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.willDisplayFooterView(NibHeaderFooterView.self, { _,_,_ in})
            manager.editingStyle(forItem: Int.self, { _,_ in return .none })
            manager.shouldIndentWhileEditing(NibCell.self, { _,_,_ in return true })
            manager.didEndDisplaying(NibCell.self, { _,_,_ in })
            manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _,_,_ in })
            manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _,_,_ in })
            manager.shouldShowMenu(for: NibCell.self, { _,_,_ in return true})
            manager.canPerformAction(for: NibCell.self, { _,_,_,_,_ in return true })
            manager.performAction(for: NibCell.self, { _,_,_,_,_ in })
            manager.shouldHighlight(NibCell.self, { _,_,_ in return true })
            manager.didHighlight(NibCell.self, { _,_,_ in })
            manager.didUnhighlight(NibCell.self, { _,_,_ in })
            #if os(iOS) && swift(>=3.2)
            if #available(iOS 11, *) {
                manager.itemsForBeginningDragSession(from: NibCell.self, { (_, _, _, _) in [] })
                manager.itemsForAddingToDragSession(from: NibCell.self, { (_, _, _, _, _) in [] })
                manager.dragPreviewParameters(for: NibCell.self, { (_, _, _) in nil })
                manager.dragSessionWillBegin{ _ in }
                manager.dragSessionDidEnd{ _ in }
                manager.dragSessionAllowsMoveOperation{ _ in false }
                manager.dragSessionIsRestrictedToDraggingApplication{ _ in false }
            }
            #endif
        }
    }
    
    func testSearchForEventPerfomance() {
        let manager = self.controller.manager
        controller.tableView = UITableView()
        #if swift(>=4.1)
        manager.anomalyHandler.anomalyAction = { _ in }
        #endif
        manager.commitEditingStyle(for: NibCell.self, { _,_,_,_ in })
        manager.canEditCell(withItem: Int.self, { _,_ in return true })
        manager.canMove(NibCell.self, { _,_,_ in return true })
        manager.heightForCell(withItem: Int.self, { _,_ in return 44 })
        manager.estimatedHeightForCell(withItem: Int.self, { _,_ in return 44 })
        manager.indentationLevelForCell(withItem: Int.self,  { _,_ in return 0})
        manager.willDisplay(NibCell.self, { _,_,_ in })
        manager.accessoryButtonTapped(in: NibCell.self, { _,_,_ in })
        manager.willSelect(NibCell.self, {_,_,_ in return indexPath(0, 0)})
        manager.didSelect(NibCell.self, {_,_,_ in})
        manager.willDeselect(NibCell.self, {_,_,_ in return indexPath(0, 0)} )
        manager.didDeselect(NibCell.self, { _,_,_ in return })
        manager.heightForHeader(withItem: Int.self, { _,_ in return 20 })
        manager.heightForFooter(withItem: Int.self, { _,_ in return 20 })
        manager.estimatedHeightForHeader(withItem: Int.self, { _,_ in return 20 })
        manager.estimatedHeightForFooter(withItem: Int.self, { _,_ in return 20 })
        manager.willDisplayHeaderView(NibHeaderFooterView.self, { _,_,_ in })
        manager.willDisplayFooterView(NibHeaderFooterView.self, { _,_,_ in})
        manager.editingStyle(forItem: Int.self, { _,_ in return .none })
        manager.shouldIndentWhileEditing(NibCell.self, { _,_,_ in return true })
        manager.didEndDisplaying(NibCell.self, { _,_,_ in })
        manager.didEndDisplayingHeaderView(NibHeaderFooterView.self, { _,_,_ in })
        manager.didEndDisplayingFooterView(NibHeaderFooterView.self, { _,_,_ in })
        manager.shouldShowMenu(for: NibCell.self, { _,_,_ in return true})
        manager.canPerformAction(for: NibCell.self, { _,_,_,_,_ in return true })
        manager.performAction(for: NibCell.self, { _,_,_,_,_ in })
        manager.shouldHighlight(NibCell.self, { _,_,_ in return true })
        manager.didHighlight(NibCell.self, { _,_,_ in })
        manager.didUnhighlight(NibCell.self, { _,_,_ in })
        
        manager.register(NibCell.self)
        manager.memoryStorage.addItem(5)
        measure {
            manager.tableDelegate?.tableView(self.controller.tableView, didSelectRowAt: indexPath(0, 0))
        }
    }
    
#if swift(>=4.1)
    func testModelEventCalledWithCellTypeLeadsToAnomaly() {
        let exp = expectation(description: "Model event called with cell")
        let anomaly = DTTableViewManagerAnomaly.modelEventCalledWithCellClass(modelType: "NibCell", methodName: "canEditCell(withItem:_:)", subclassOf: "UITableViewCell")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.canEditCell(withItem: NibCell.self) { _, _ in true }
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "    ⚠️[DTTableViewManager] Event canEditCell(withItem:_:) registered with model type, that happens to be a subclass of UITableViewCell: NibCell.\n\n    This is likely not what you want, because this event expects to receive model type used for current indexPath instead of cell/view.\n    Reasoning behind it is the fact that for some events views have not yet been created(for example: tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)).\n    Because they are not created yet, this event cannot be called with cell/view object, and even it\'s type is unknown at this point, as the mapping resolution will happen later.\n\n    Most likely you need to use model type, that will be passed to this cell/view through ModelTransfer protocol.\n    For example, for height of cell that expects to receive model Int, event would look like so:\n            \n        manager.heightForCell(withItem: Int.self) { model, indexPath in\n            return 44\n        }")
    }
    
    func testUnusedEventLeadsToAnomaly() {
        let exp = expectation(description: "Unused event")
        let anomaly = DTTableViewManagerAnomaly.unusedEventDetected(viewType: "StringCell", methodName: "didSelect")
        controller.manager.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        controller.manager.didSelect(StringCell.self) { _, _, _ in }
        waitForExpectations(timeout: 1.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️[DTTableViewManager] didSelect event registered for StringCell, but there were no view mappings registered for StringCell type. This event will never be called.")
    }
#endif
}

