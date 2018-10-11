import UIKit
import RxSwift

@IBDesignable
class DepartureDetailsContentView: DepartureDetailsContentBaseView {

    @IBOutlet internal weak var indicator: UIActivityIndicatorView!

    private var journeyDetailsDisposeBag = DisposeBag()
    private var departureModel: DepartureCellModel!
    private let activityMonitor = ActivityIndicator()

    let cellHeight: CGFloat = 46

    func setup(model: DepartureCellModel) {
        currentOrigin = StopDataHandler.shared.currentOrigin

        setupActivityMonitor()
        setupObservables()

        manager.startManaging(withDelegate: self)
        manager.register(DepartureDetailsCell.self)

        manager.configure(DepartureDetailsCell.self) { (cell, cellModel, indexPath) in
            cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? .blue3 : .blue31

            let topColor: UIColor = indexPath.row != 0 ? model.fgColor : .clear
            let bottomColor = (indexPath.row + 1) != self.storage.items(inSection: 0)?.count ? model.fgColor : .clear
            cell.setupLines(topColor: topColor, bottomColor: bottomColor)
        }

        manager.heightForCell(withItem: JourneyDetailStopCellModel.self) { (cellModel, indexPath) -> CGFloat in
            return self.cellHeight
        }

        refresh(model: model)
    }

    private func setupActivityMonitor() {
        activityMonitor
            .asDriver()
            .drive(onNext: { isActive in
                UIApplication.shared.isNetworkActivityIndicatorVisible = isActive

                if isActive && (self.storage.items(inSection: 0).isNil || self.storage.items(inSection: 0)!.isEmpty) {
                    self.indicator.startAnimating()
                    self.indicator.fadeIn(duration: .fade)
                } else {
                    self.indicator.stopAnimating()
                    self.indicator.fadeOut(duration: .fade)
                }
            })
            .disposed(by: disposeBag)
    }

    private func updateStops(journeyDetail: JourneyDetail) {
        guard let currentStop = (journeyDetail.stops.first { $0.id == departureModel.departure.stopId }) else { return }

        if let stops = Array(journeyDetail.stops.split { $0 == currentStop }).last {
            var stops = Array(stops)
            stops.insert(currentStop, at: 0)

            storage.setItems(stops.compactMap({ JourneyDetailStopCellModel(stop: $0) }))
        }
    }

    private func refresh(model: DepartureCellModel) {
        departureModel = model

        infoLabel.fadeOut()
        getJourneyDetail()
    }

    private func getJourneyDetail() {
        journeyDetailsDisposeBag = DisposeBag()

        VasttrafikService.shared.getJourneyDetail(ref: departureModel.journeyDetailRef)
            .trackActivity(activityMonitor)
            .subscribe(onNext: { journeyDetail in
                self.updateStops(journeyDetail: journeyDetail)
            }, onError: { error in
                self.infoLabel.fadeIn(duration: .fade)
                self.storage.removeAllItems()

                debugErrorPrint(error)
            })
            .disposed(by: journeyDetailsDisposeBag)
    }

    private func setupObservables() {
        currentOriginUpdatedObservable
            .subscribe(onNext: { stop in
                if let stop = stop {
                    if stop != self.currentOrigin { self.hideCallback?() }
                } else {
                    if !self.currentOrigin.isNil {
                        if StopDataHandler.shared.closestOrigins.first != self.currentOrigin { self.hideCallback?() }
                    }
                }

                self.currentOrigin = stop
            })
            .disposed(by: disposeBag)

        currentDestinationsUpdatedObservable
            .subscribe(onNext: { if !$0.isNil { self.hideCallback?() }})
            .disposed(by: disposeBag)
    }
}
