import UIKit
import DTTableViewManager
import DTModelStorage

class DepartureListHandler: DTTableViewManageable {

    var tableView: UITableView!
    
    private var didSelect: ValueCallback<DepartureCellModelItem>?
    private var noDeparturesCallback: Callback?
    private var storage: MemoryStorage { return manager.memoryStorage }
    private var departureItems = [DepartureItem]()

    func setup(for tableView: UITableView, in viewController: DepartureViewController, selectionCallback: ValueCallback<DepartureCellModelItem>? = nil, noDeparturesCallback: Callback? = nil) {
        self.tableView = tableView
        self.didSelect = selectionCallback
        self.noDeparturesCallback = noDeparturesCallback

        manager.startManaging(withDelegate: self)
        manager.register(DepartureCell.self)

        manager.configure(DepartureCell.self) { (cell, model, indexPath) in
            cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? .blue2 : .blue1
        }

        manager.didSelect(DepartureCell.self) { [unowned self] (cell, model, indexPath) in
            self.didSelect?(model)
        }
    }

    func append(items: [DepartureItem]) {
        departureItems.append(contentsOf: items)
    }

    func renderDepartures(isLast: Bool = false) {
        guard let departures = departureItems as? [Departure] else { return }
        if !isLast && departures.isEmpty { return }

        let departureModels = SortHandler.shared.aggregateDepartures(departures: departures)

        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.storage.setItems(departureModels)
        })

        if isLast && departureModels.isEmpty { self.noDeparturesCallback?() }
        if isLast { PublishSubjects.shared.departuresFetchedSubject.onNext(departureModels) }
    }

    func renderTrips(isLast: Bool = false) {
        guard let trips = departureItems as? [Trip] else { return }
        if !isLast && trips.isEmpty { return }

        let tripModels = SortHandler.shared.aggregateTrips(trips: trips)

        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.storage.setItems(tripModels)
        })

        if isLast && tripModels.isEmpty { self.noDeparturesCallback?() }
        if isLast { PublishSubjects.shared.tripsFetchedSubject.onNext(tripModels) }
    }

    func removeAllItems(completely: Bool = false) {
        departureItems.removeAll()
        if completely { storage.removeAllItems() }
    }
}
