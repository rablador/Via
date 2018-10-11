import UIKit
import DTTableViewManager
import DTModelStorage
import RxSwift

class SearchResultViewController: UIViewController, DTTableViewManageable {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var infoLabel: InfoLabel!

    private let searchInputObservable: Observable<String> = PublishSubjects.shared.searchInputSubject
    private var disposeBag = DisposeBag()
    private var searchDisposeBag = DisposeBag()
    private var storage: MemoryStorage { return manager.memoryStorage }
    private (set) var searchType = Constants.SearchType.origin

    private var currentSections = [SearchResultSectionHeaderModel]() {
        didSet { storage.setSectionHeaderModels(currentSections) }
    }

    private let searchResultSectionModels = [
        SearchResultSectionHeaderModel(title: "SÖKRESULTAT")
    ]

    private let originSectionModels = [
        SearchResultSectionHeaderModel(title: "SENASTE"),
        SearchResultSectionHeaderModel(title: "I NÄRHETEN")
    ]

    private let destinationSectionModels = [
        SearchResultSectionHeaderModel(title: "SENASTE")
    ]

    var didSelectOriginSearchResultCell: ValueCallback<SearchResultCellModel>?
    var didSelectDestinationSearchResultCell: ValueCallback<SearchResultCellModel>?
    var didSelectFavoriteDestinationSearchResultCell: ValueCallback<SearchResultCellModel>?

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.startManaging(withDelegate: self)
        manager.register(SearchResultCell.self)
        manager.registerHeader(SearchResultSectionHeader.self)

        manager.configuration.displayHeaderOnEmptySection = false
        TableViewUpdater(tableView: tableView).deleteSectionAnimation = .none

        manager.configure(SearchResultCell.self) { (cell, model, indexPath) in
            cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? .blue1 : .blue2
        }

        manager.didSelect(SearchResultCell.self) { [unowned self] (cell, model, indexPath) in
            switch self.searchType {
            case .origin:
                self.didSelectOriginSearchResultCell?(model)
            case .destination:
                self.didSelectDestinationSearchResultCell?(model)
            case .favoriteDestination:
                self.didSelectFavoriteDestinationSearchResultCell?(model)
            }
        }

        setupObservables()
    }

    func activateOriginSearch() {
        searchType = .origin

        clearResults()
        setOriginSearchSections()

        view.fadeIn(duration: .fade)
    }

    func activateDestinationSearch() {
        searchType = .destination

        clearResults()
        setDestinationSearchSections()

        view.fadeIn(duration: .fade)
    }

    func activateFavoriteDestinationSearch() {
        searchType = .favoriteDestination

        clearResults()
        setDestinationSearchSections()

        view.fadeIn(duration: .fade)
    }

    func deactivateSearch() {
        disposeBag = DisposeBag()
        searchDisposeBag = DisposeBag()
        clearResults()
    }

    func clearResults() {
        self.storage.removeAllItems()
    }

    private func setOriginSearchSections() {
        currentSections = originSectionModels

        let searchedOriginModels = StopDataHandler.shared.searchedOrigins
            .filter { stop in
                let closestStop = (StopDataHandler.shared.currentOrigin.isNil && !StopDataHandler.shared.closestOrigins.first.isNil) ? StopDataHandler.shared.closestOrigins.first : nil
                return (stop != StopDataHandler.shared.currentOrigin) && (stop != closestStop)
            }
            .compactMap { SearchResultCellModel(stop: $0) }
        storage.setItems(Array(searchedOriginModels.prefix(5)), forSection: 0)

        let closestOriginModels = StopDataHandler.shared.closestOrigins
            .filter { stop in
                let closestStop = (StopDataHandler.shared.currentOrigin.isNil && !StopDataHandler.shared.closestOrigins.first.isNil) ? StopDataHandler.shared.closestOrigins.first : nil
                return (stop != StopDataHandler.shared.currentOrigin) && (stop != closestStop)
            }
            .compactMap { SearchResultCellModel(stop: $0) }
        storage.setItems(Array(closestOriginModels.prefix(5)), forSection: 1)
    }

    private func setDestinationSearchSections() {
        currentSections = destinationSectionModels

        let searchedDestinationModels = StopDataHandler.shared.searchedDestinations
            .filter { !(StopDataHandler.shared.currentSearches ?? [Stop]()).contains($0) }
            .filter { !((searchType == .favoriteDestination) && ($0.type == .address)) }
            .compactMap { SearchResultCellModel(stop: $0) }
        storage.setItems(searchedDestinationModels, forSection: 0)
    }

    private func setupObservables() {
        infoLabel.clear()

        searchInputObservable
            .distinctUntilChanged()
            .subscribe(onNext: { searchText in
                if searchText.isEmpty {
                    self.searchType == .origin ? self.setOriginSearchSections() : self.setDestinationSearchSections()
                } else {
                    self.searchStops(searchString: searchText)
                }
            })
            .disposed(by: disposeBag)

        VasttrafikService.shared.getNearbyStops()
            .subscribe(onNext: { _ in if self.searchType == .origin { self.setOriginSearchSections() } })
            .disposed(by: disposeBag)
    }

    private func searchStops(searchString: String) {
        searchDisposeBag = DisposeBag()

        VasttrafikService.shared.searchStops(searchString: searchString)
            .subscribe(onNext: { stops in
                self.storage.removeAllItems()
                self.currentSections = self.searchResultSectionModels

                var cellModels = stops.compactMap { SearchResultCellModel(stop: $0) }
                cellModels = self.searchType == .destination ? cellModels : cellModels.filter { $0.stop.type == .stop }

                self.storage.setItems(cellModels)
            }, onError: { error in
                self.storage.removeAllItems()

                self.infoLabel.set(error: error)
                debugErrorPrint(error)
            }, onCompleted: {})
            .disposed(by: searchDisposeBag)
    }
}
