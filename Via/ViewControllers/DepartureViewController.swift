import UIKit
import CoreLocation
import Moya
import RxSwift
import Alamofire

class DepartureViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var infoLabel: InfoLabel!

    private let disposeBag = DisposeBag()
    private var departureDisposeBag = DisposeBag()
    private let commuteUpdatedObservable: Observable<Commute?> = PublishSubjects.shared.currentCommuteUpdatedSubject
    private let currentOriginUpdatedObservable: Observable<Stop?> = PublishSubjects.shared.currentOriginUpdatedSubject
    private let currentDestinationsUpdatedObservable: Observable<[Stop]?> = PublishSubjects.shared.currentDestinationsUpdatedSubject
    private let currentTimeUpdatedObservable: Observable<Time> = PublishSubjects.shared.currentTimeUpdatedSubject

    private let departureListHandler = DepartureListHandler()
    private let activityMonitor = ActivityIndicator()
    private let refreshControl = UIRefreshControl()
    private var canRefresh = true
    private let refreshPeriod: Double = 55
    private var refreshTimer = Timer()
    private var origHeight: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        departureListHandler.setup(for: tableView, in: self, selectionCallback: addDepartureDetailsView, noDeparturesCallback: noDepartures)

        setupActivityMonitor()
        setupReachability()
        setupRefreshControl()
        resetRefreshTimer()
        setupObservables()
    }

    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if origHeight.isNil { origHeight = view.height }
    }

    func searchAddressStops(address: Stop, isDestination: Bool = true) {
        infoLabel.clear()
        departureDisposeBag = DisposeBag()

        VasttrafikService.shared.getNearbyStops(location: address.location)
            .subscribe(onNext: { stops in
                if isDestination {
                    Array(stops.prefix(3)).saveCurrentSearches()
                } else {
                    stops.first?.saveCurrentOrigin()
                }
            }, onError: { error in
                self.departureListHandler.removeAllItems(completely: true)

                self.infoLabel.set(error: error)
                debugErrorPrint(error)
            })
            .disposed(by: departureDisposeBag)
    }

    private func setupActivityMonitor() {
        activityMonitor
            .asDriver()
            .drive(onNext: { isActive in
                UIApplication.shared.isNetworkActivityIndicatorVisible = isActive
                if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
                if !isActive { self.resetRefreshTimer() }
            })
            .disposed(by: disposeBag)
    }

    private func setupReachability() {
        ReachabilityHandler.shared.didBecomeReachable.subscribe(onNext: { status in
            if case .reachable = status {
                self._getDepartures()
            } else {
                debugErrorPrint(DebugError("No network.", type: .network))
            }
        })
        .disposed(by: disposeBag)
    }

    private func resetRefreshTimer() {
        refreshTimer.invalidate()
        refreshTimer = Timer.scheduledTimer(timeInterval: refreshPeriod, target: self, selector: #selector(_getDepartures), userInfo: nil, repeats: true)
    }

    private func setupRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(_getDepartures), for: .valueChanged)

        tableView.addSubview(refreshControl)
        tableView.sendSubviewToBack(refreshControl)
    }

    private func setupObservables() {
        commuteUpdatedObservable
            .subscribe(onNext: { commute in
                self._getDepartures()
                debugPrint("commuteUpdated - " + (commute?.fromStop?.name ?? "nil"))
            })
            .disposed(by: disposeBag)

        currentOriginUpdatedObservable
            .subscribe(onNext: { stop in
                self._getDepartures()
                debugPrint("currentOriginUpdated - " + (stop?.name ?? "nil"))
            })
            .disposed(by: disposeBag)

        currentDestinationsUpdatedObservable
            .subscribe(onNext: { stops in
                self._getDepartures()
                debugPrint("currentDestinationsUpdated - " + (stops?.compactMap { $0.name }.joined(separator: ", ") ?? "nil"))
            })
            .disposed(by: disposeBag)

        currentTimeUpdatedObservable
            .subscribe(onNext: { time in
                self._getDepartures()
                debugPrint("currentTimeUpdated - \(time.timeShift.rawValue)")
            })
            .disposed(by: disposeBag)
    }

    private func getDepartures(date: Date = StopDataHandler.shared.currentTime.departureDate, origin: Stop? = StopDataHandler.shared.currentOrigin) {
        var allowRender = true
        let dispatch = DispatchGroup()

        dispatch.enter()
        VasttrafikService.shared.getDepartures(at: date, origin: origin)
            .trackActivity(activityMonitor)
            .subscribe(onNext: { departures in
                self.departureListHandler.append(items: departures)

                if allowRender {
                    allowRender = false
                    self.departureListHandler.renderDepartures()

                    dispatch.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dispatch.leave() }
                }
            }, onError: { error in
                self.departureListHandler.removeAllItems(completely: true)
                dispatch.leave()

                self.infoLabel.set(error: error)
                debugErrorPrint(error)
            }, onCompleted: { dispatch.leave() })
            .disposed(by: departureDisposeBag)

        dispatch.notify(queue: .main) { self.departureListHandler.renderDepartures(isLast: true) }
    }

    private func getTrips(date: Date = StopDataHandler.shared.currentTime.departureDate, origin: Stop? = StopDataHandler.shared.currentOrigin, destinations: [Stop] = StopDataHandler.shared.currentDestinations ?? [Stop](), isDeparture: Bool = true) {
        var allowRender = true
        let dispatch = DispatchGroup()

        dispatch.enter()
        VasttrafikService.shared.getTrips(at: date, origin: origin, destinations: destinations, isDeparture: isDeparture)
            .trackActivity(activityMonitor)
            .subscribe(onNext: { trips in
                self.departureListHandler.append(items: trips)

                if allowRender {
                    allowRender = false
                    self.departureListHandler.renderTrips()

                    dispatch.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dispatch.leave() }
                }
            }, onError: { error in
                self.departureListHandler.removeAllItems(completely: true)
                dispatch.leave()

                self.infoLabel.set(error: error)
                debugErrorPrint(error)
            }, onCompleted: { dispatch.leave() })
            .disposed(by: departureDisposeBag)

        dispatch.notify(queue: .main) { self.departureListHandler.renderTrips(isLast: true) }
    }

    private func addDepartureDetailsView(model: DepartureCellModelItem) {
        if let departureModel = model as? DepartureCellModel {
            let departureDetailsView = DepartureDetailsView()
            view.addSubview(departureDetailsView)

            departureDetailsView.setup(model: departureModel, origHeight: origHeight!)
            departureDetailsView.show()
        } else if let tripModel = model as? TripCellModel {
            let tripDetailsView = TripDetailsView()
            view.addSubview(tripDetailsView)

            tripDetailsView.setup(model: tripModel, origHeight: origHeight!)
            tripDetailsView.show()
        }
    }

    private func noDepartures() {
        infoLabel.set(text: "Inga närliggande avgångar...")
    }

    @objc private func _getDepartures() {
        PublishSubjects.shared.fetchingDeparturesSubject.onNext(())

        infoLabel.clear()
        departureDisposeBag = DisposeBag()
        departureListHandler.removeAllItems()

        if let commute = StopDataHandler.shared.currentCommute {
            if let toStops = commute.toStops {
                getTrips(date: commute.date, origin: commute.fromStop, destinations: toStops, isDeparture: commute.isDeparture)
            } else {
                getDepartures(date: commute.date, origin: commute.fromStop)
            }
        } else {
            StopDataHandler.shared.currentDestinations.isNil ? getDepartures() : getTrips()
        }
    }
}
