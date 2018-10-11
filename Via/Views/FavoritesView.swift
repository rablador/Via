import UIKit
import RxSwift
import DTCollectionViewManager
import DTModelStorage

@IBDesignable
class FavoritesView: DestinationsView {

    private let favoritesUpdatedObservable: Observable<[Favorite]> = PublishSubjects.shared.favoritesUpdatedSubject
    private let currentFavoriteUpdatedObservable: Observable<Favorite?> = PublishSubjects.shared.currentFavoriteUpdatedSubject
    private let disposeBag = DisposeBag()

    var searchButtonCallback: Callback?

    override func awakeFromNib() {
        super.awakeFromNib()

        manager.configure(DestinationCell.self) { (cell, model, indexPath) in
            let model = model as! FavoriteCellModel
            cell.set(selected: model.favorite == StopDataHandler.shared.currentFavorite, animated: false)
        }

        manager.didSelect(DestinationCell.self) { (cell, model, indexPath) in
            let model = model as! FavoriteCellModel

            if model.isSearchButton {
                self.searchButtonCallback?()
                return
            }

            if model.favorite == StopDataHandler.shared.currentFavorite {
                Favorite.removeCurrent()
            } else {
                model.favorite.saveCurrent()
            }

            self.collectionView?.reloadData()
        }

        setupObservables()
    }

    internal override func fetchingDepartures() {
        updateItemPositions()
    }

    private func updateItemPositions() {
        guard let currentItem = StopDataHandler.shared.currentFavorite else { return }

        collectionView!.layoutIfNeeded()

        let allItems = StopDataHandler.shared.favorites
        let visibleItems = (collectionView!.visibleCells as! [DestinationCell]).map { ($0.model as! FavoriteCellModel).favorite }

        var visibleIndices = [Int]()
        visibleItems.forEach { item in
            if let index = allItems.index(of: item) { visibleIndices.append(index) }
        }

        guard let currentIndex = allItems.index(of: currentItem) else { return }

        super.updateItemPositions(allIndices: Array(allItems.indices), visibleIndices: visibleIndices, currentIndex: currentIndex + 1, leftModifier: 0) // +1 to account for search index.
    }

    private func setupObservables() {
        favoritesUpdatedObservable
            .subscribe(onNext: { favorites in
                var items = [FavoriteCellModel(favorite: Favorite.defaultFavorite, isSearchButton: true)]
                items.append(contentsOf: favorites.compactMap { FavoriteCellModel(favorite: $0, isSearchButton: false) })
                self.favoriteCellModelItems = items
            })
            .disposed(by: disposeBag)

        currentFavoriteUpdatedObservable
            .subscribe(onNext: { if $0.isNil { self.collectionView?.reloadData() }})
            .disposed(by: disposeBag)
    }
}
