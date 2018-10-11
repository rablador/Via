import UIKit
import RxSwift
import DTCollectionViewManager
import DTModelStorage

@IBDesignable
class SearchesView: DestinationsView {

    private let currentSearchesUpdatedObservable: Observable<[Stop]?> = PublishSubjects.shared.currentSearchesUpdatedSubject
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        manager.didSelect(DestinationCell.self) { [unowned self] (cell, model, indexPath) in
            if self.favoriteCellModelItems.count == 1 { self.fadeOut(duration: .fast) }

            let model = model as! SearchCellModel
            model.stop.removeCurrentSearch()
        }

        setupObservables()
    }

    private func setupObservables() {
        currentSearchesUpdatedObservable
            .subscribe(onNext: { stops in
                if let stops = stops, !stops.isEmpty {
                    self.favoriteCellModelItems = stops.compactMap { SearchCellModel(stop: $0) }
                    self.fadeIn(duration: .fast)
                }
            })
            .disposed(by: disposeBag)
    }
}
