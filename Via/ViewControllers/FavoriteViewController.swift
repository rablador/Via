import UIKit
import DTTableViewManager
import DTModelStorage

class FavoriteViewController: UIViewController, DTTableViewManageable {

    @IBOutlet private weak var topView: FavoriteTopView! { didSet {
        topView.newButtonCallback = didTapNewButton
        topView.changeButtonCallback = didTapChangeButton
        topView.closeButtonCallback = didTapCloseButton
    }}
    @IBOutlet weak var tableView: UITableView!

    private var searchResultViewController: SearchResultViewController? { didSet {
        searchResultViewController?.didSelectFavoriteDestinationSearchResultCell = addSearched
    }}

    private var storage: MemoryStorage { return manager.memoryStorage }
    private var selectedRow = -1
    private var searchingStopsModel: FavoriteStopSectionCellModel?
    private let defaultRowHeight: CGFloat = 56

    override func viewDidLoad() {
        super.viewDidLoad()

        topView.toggleChangeButton(!StopDataHandler.shared.favorites.isEmpty)

        manager.startManaging(withDelegate: self)
        manager.register(FavoriteStopSectionCell.self)

        manager.configure(FavoriteStopSectionCell.self) { [unowned self] (cell, model, indexPath) in
            cell.backgroundColor = (indexPath.row % 2 == 0) ? .blue3 : .blue2

            cell.deleteButtonCallback = { self.delete(model: model) }
            cell.editButtonCallback = { self.edit(model: model) }
            cell.stopDeleteButtonCallback = { self.delete(stop: $0, from: model) }
            cell.addStopButtonCallback = {
                self.searchingStopsModel = model
                self.addSearchViewController()
                self.topView.toggleSearch(show: true)
            }

            cell.toggleButtons(show: self.tableView.isEditing, animated: false)
        }

        manager.heightForCell(withItem: FavoriteStopSectionCellModel.self) { [unowned self] (model, indexPath) -> CGFloat in
            if indexPath.row == self.selectedRow {
                return self.defaultRowHeight + CGFloat(model.stops.count * 46) + (model.stops.count < 3 ? 46 : 0)
            }

            return self.defaultRowHeight
        }

        manager.didSelect(FavoriteStopSectionCell.self) { [unowned self] (cell, model, indexPath) in
            self.selectedRow = indexPath.row == self.selectedRow ? -1 : indexPath.row

            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

        manager.editingStyle(forItem: FavoriteStopSectionCellModel.self) { (model, indexPath) -> UITableViewCell.EditingStyle in
            .none
        }

        manager.move(FavoriteStopSectionCell.self) { [unowned self] (toIndexPath, cell, model, fromIndexPath) in
            var favorites = StopDataHandler.shared.favorites

            favorites.rearrange(fromIndex: fromIndexPath.row, toIndex: toIndexPath.row)
            favorites.save()

            self.storage.setItems(favorites.compactMap { FavoriteStopSectionCellModel(favorite: $0) })
        }

        self.storage.setItems(StopDataHandler.shared.favorites.compactMap { FavoriteStopSectionCellModel(favorite: $0) })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        didTapCloseButton()
        manager.updateVisibleCells { cell in
            self.selectedRow = -1
            self.tableView.reloadData()
        }
    }

    func addSearched(searchModel: SearchResultCellModel) {
        guard let model = searchingStopsModel else { return }

        var favorite = model.favorite
        favorite.add(stop: searchModel.stop)
        favorite.save()

        do { try self.storage.replaceItem(model, with: FavoriteStopSectionCellModel(favorite: favorite)) } catch {}
        searchModel.stop.saveSearchedDestination()

        didTapCloseButton()
    }

    private func addSearchViewController() {
        if !searchResultViewController.isNil { return }

        let viewController = UIStoryboard.main.viewController(ofType: SearchResultViewController.self)
        viewController.view.fadeOut()

        addChild(viewController)
        viewController.didMove(toParent: self)
        view.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        viewController.activateFavoriteDestinationSearch()
        searchResultViewController = viewController
    }

    private func removeSearchViewController(completion: Callback? = nil) {
        if searchResultViewController.isNil {
            completion?()
            return
        }

        searchResultViewController?.deactivateSearch()
        removeOverlay(viewController: searchResultViewController!, fade: true, completion: {
            self.searchResultViewController = nil
            completion?()
        })
    }

    private func didTapNewButton() {
        let saveDialog = FavoriteDialogController() {
            let model = FavoriteStopSectionCellModel(favorite: $0)

            self.storage.addItem(model)
            self.topView.toggleChangeButton(!StopDataHandler.shared.favorites.isEmpty)

            self.selectedRow = (self.storage.items(inSection: 0) ?? []).count - 1
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        present(saveDialog, animated: true)
    }

    private func didTapChangeButton() {
        topView.setChangeButtonTitle(tableView.isEditing ? "ÄNDRA" : "KLAR")
        topView.toggleNewButton(tableView.isEditing)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableView.beginUpdates()
            self.tableView.isEditing = !self.tableView.isEditing
            self.tableView.endUpdates()

            self.manager.updateVisibleCells { cell in
                let cell = cell as! FavoriteStopSectionCell

                if self.tableView.isEditing {
                    cell.toggleButtons(show: true)
                } else {
                    cell.toggleButtons(show: false)
                }
            }
        }

        if !self.tableView.isEditing {
            tableView.beginUpdates()
            self.selectedRow = -1
            tableView.endUpdates()
        }
        CATransaction.commit()
    }

    private func didTapCloseButton() {
        removeSearchViewController()
        topView.toggleSearch(show: false)
    }

    private func edit(model: FavoriteStopSectionCellModel) {
        let editDialog = FavoriteDialogController(favorite: model.favorite) { favorite in
            do { try self.storage.replaceItem(model, with: FavoriteStopSectionCellModel(favorite: favorite)) } catch {}
        }

        present(editDialog, animated: true)
    }

    private func delete(model: FavoriteStopSectionCellModel) {
        model.favorite.remove()
        if model.favorite == StopDataHandler.shared.currentFavorite { Favorite.removeCurrent() }

        do { try self.storage.removeItem(model) } catch {}

        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })

        if StopDataHandler.shared.favorites.isEmpty {
            topView.toggleChangeButton(false)
            didTapChangeButton()
        }

        // Todo: Text om inga favs
    }

    private func delete(stop: Stop, from model: FavoriteStopSectionCellModel) {
        var favorite = model.favorite
        favorite.remove(stop: stop)
        favorite.save()

        do { try self.storage.replaceItem(model, with: FavoriteStopSectionCellModel(favorite: favorite)) } catch {}
    }
}
