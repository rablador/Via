import UIKit
import RxSwift
import DTCollectionViewManager
import DTModelStorage

@IBDesignable
class TimeView: CollectionViewBase, DTCollectionViewManageable {

    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var infoView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var departureLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!

    private let currentDestinationsUpdatedObservable: Observable<[Stop]?> = PublishSubjects.shared.currentDestinationsUpdatedSubject
    private let commuteUpdatedObservable: Observable<Commute?> = PublishSubjects.shared.currentCommuteUpdatedSubject
    private let currentTimeUpdatedObservable: Observable<Time> = PublishSubjects.shared.currentTimeUpdatedSubject
    private let disposeBag = DisposeBag()
    private var storage: MemoryStorage { return manager.memoryStorage }

    private var date = Date()
    private var isDeparture = true
    private let fullDateFormatter = DateFormatter.timeViewFormatter
    private let timeFormatter = DateFormatter.timeFormatter
    private let weekTimeFormatter = DateFormatter.weekTimeFormatter
    private var calendar = Calendar(identifier: .gregorian)

    private var topConstraint: NSLayoutConstraint!
    private var isOnScreen: Bool { return topConstraint.constant == 0 }

    var timePlannerView: TimePlannerView?

    override func awakeFromNib() {
        super.awakeFromNib()

        topConstraint = superview?.constraints.first { $0.identifier == "timeViewTopConstraint" }

        manager.startManaging(withDelegate: self)
        manager.register(TimeCell.self)

        manager.configure(TimeCell.self) { (cell, model, indexPath) in
            cell.set(selected: model.time == StopDataHandler.shared.currentTime, animated: false)
        }

        manager.sizeForCell(withItem: TimeCellModel.self) { (model, indexPath) -> CGSize in
            let size = model.title.size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
            return CGSize(width: size.width + 16 + 5, height: 28)
        }

        manager.didSelect(TimeCell.self) { [unowned self] (cell, model, indexPath) in
            if model.time == StopDataHandler.shared.currentTime {
                Time.removeCurrent()
            } else {
                model.time.saveCurrent()
            }

            self.collectionView?.reloadData()
        }

        storage.setItems(Constants.TimeShift.all.compactMap { TimeCellModel(time: Time(timeShift: $0)) }, forSection: 0)
        setupObservables()

        calendar.firstWeekday = 2 // Monday
    }

    func toggle() {
        if isOnScreen {
            topConstraint.constant = -58
            removeTimePlannerView()

            if Time.isFuture { Commute.removeCurrent() }
            if StopDataHandler.shared.currentTime.timeShift != .now { Time.removeCurrent() }

            UIView.animate(duration: .fade, animations: { self.superview?.layoutIfNeeded() }) { if self.infoView.isVisible {
                self.infoView.fadeOut(duration: .fast) }

                self.collectionView?.contentOffset = CGPoint(x: 0, y: 0)
                self.collectionView?.reloadData()
            }
        } else {
            topConstraint.constant = 0
            UIView.animate(duration: .fade, animations: { self.superview?.layoutIfNeeded() })
        }
    }

    @IBAction func didPressSettingsButton(_ sender: UIButton) {
        if Time.isFuture {
            let storedDate = StopDataHandler.shared.currentCommute!.date
            date = storedDate.compare(Date()) == .orderedAscending ? Date() : storedDate
            isDeparture = StopDataHandler.shared.currentCommute!.isDeparture
        }
        updateInfoLabel()

        infoView.fadeIn(duration: .fast)
        addTimePlannerView()
    }

    @IBAction func didPressCloseButton(_ sender: UIButton) {
        Commute.removeCurrent()

        infoView.fadeOut(duration: .fast)
        removeTimePlannerView()

        date = Date()
        isDeparture = true
    }

    @IBAction func didPressInfoButton(_ sender: UIButton) {
        addTimePlannerView()
    }

    internal override func fetchingDepartures() {
        updateItemPositions()
    }

    private func updateInfoLabel() {
        departureLabel.text = isDeparture ? "AVGÅNG" : "ANKOMST"

        if calendar.isDateInToday(date) {
            infoLabel.text = "idag " + timeFormatter.string(from: date)
        } else if calendar.isDateInTomorrow(date) {
            infoLabel.text = "imorgon " + timeFormatter.string(from: date)
        } else if calendar.isDate(Date(), equalTo: date, toGranularity: .weekOfYear) {
            infoLabel.text = weekTimeFormatter.string(from: date)
        } else {
            infoLabel.text = fullDateFormatter.string(from: date)
        }
    }

    private func addTimePlannerView() {
        if !timePlannerView.isNil { return }

        timePlannerView = TimePlannerView(frame: CGRect(x: 0, y: bottom, width: superview!.width, height: superview!.height - bottom))
        timePlannerView!.toggleDepartureControl(isEnabled: !StopDataHandler.shared.currentDestinations.isNil && !StopDataHandler.shared.currentDestinations!.isEmpty, isDeparture: isDeparture)

        timePlannerView!.setup(date: date, isDeparture: isDeparture, okCallback: {
            let commute = Commute(
                date: self.date,
                isDeparture: self.isDeparture,
                fromStop: StopDataHandler.shared.currentOrigin,
                toStops: StopDataHandler.shared.currentDestinations
            )

            commute.saveCurrent()
            self.removeTimePlannerView()
        }, changeCallback: { (date: Date, isDeparture: Bool) in
            self.date = date
            self.isDeparture = isDeparture

            self.updateInfoLabel()
        }, willRemoveCallback: {
            if !Time.isFuture { self.infoView.fadeOut(duration: .fast) }
        }, didRemoveCallback: {
            self.timePlannerView?.removeFromSuperview()
            self.timePlannerView = nil
        })

        superview!.insertSubview(timePlannerView!, at: superview!.subviews.index(of: self)!)
        DispatchQueue.main.async { self.timePlannerView!.show() }
    }

    private func removeTimePlannerView() {
        if timePlannerView.isNil { return }
        timePlannerView!.hide()
    }

    private func updateItemPositions() {
        collectionView!.layoutIfNeeded()

        let allItems = Constants.TimeShift.all.map { Time(timeShift: $0) }
        let visibleItems = (collectionView!.visibleCells as! [TimeCell]).map { $0.model.time }
        let currentItem = StopDataHandler.shared.currentTime

        var visibleIndices = [Int]()
        visibleItems.forEach { item in
            if let index = allItems.index(of: item) { visibleIndices.append(index) }
        }

        guard let currentIndex = allItems.index(of: currentItem) else { return }

        super.updateItemPositions(allIndices: Array(allItems.indices), visibleIndices: visibleIndices, currentIndex: currentIndex)
    }

    private func setupObservables() {
        currentDestinationsUpdatedObservable
            .subscribe(onNext: { self.timePlannerView?.toggleDepartureControl(isEnabled: !$0.isNil && !$0!.isEmpty, isDeparture: self.isDeparture) })
            .disposed(by: disposeBag)

        commuteUpdatedObservable
            .subscribe(onNext: { commute in
                if let commute = commute {
                    let storedDate = commute.date
                    self.date = storedDate.compare(Date()) == .orderedAscending ? Date() : storedDate
                    self.isDeparture = commute.isDeparture

                    self.updateInfoLabel()

                    if !self.infoView.isVisible { self.infoView.fadeIn(duration: .fast) }

                    if !self.isOnScreen {
                        self.topConstraint.constant = 0
                        UIView.animate(duration: .fade, animations: { self.superview?.layoutIfNeeded() })
                    }
                }
            })
            .disposed(by: disposeBag)

        currentTimeUpdatedObservable
            .subscribe(onNext: { time in
                if !self.isOnScreen && (time.timeShift != .now) {
                    self.topConstraint.constant = 0
                    UIView.animate(duration: .fade, animations: { self.superview?.layoutIfNeeded() })
                }
            })
            .disposed(by: disposeBag)
    }
}
