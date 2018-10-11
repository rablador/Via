import UIKit
import RxSwift

class TripDetailsView: DepartureDetailsBaseView {
    
    @IBOutlet private weak var contentView: TripDetailsContentView!

    private let tripsFetchedObservable: Observable<[TripCellModel]> = PublishSubjects.shared.tripsFetchedSubject
    private let disposeBag = DisposeBag()

    private var containerWidth: CGFloat!
    private var tripModel: TripCellModel!

    func setup(model: TripCellModel, origHeight: CGFloat) {
        setupObservables()
        setupConstraints()

        tripModel = model
        containerWidth = superview!.width - 20

        headerView.setup(model: model)
        contentView.setup(model: model)
        footerView.setup(model: model)

        scrollView.delegate = self
        contentView.hideCallback = hide

        let nonContentHeight = container.height - scrollView.height
        var contentHeight: CGFloat = (contentView.cellHeight * (isiPhoneX ? 4 : 3)) + (contentView.legDoubleCellPartHeight * (isiPhoneX ? 2 : 1)) - (isiPhoneX ? 1 : 0)
        contentHeight = min(contentHeight, (origHeight - 58) - nonContentHeight) // -58 for TimeView.

        containerHeightConstraint.constant = contentHeight + nonContentHeight
        contentContainerWidthConstraint.constant = containerWidth

        for i in 1 ..< model.trips.count {
            let trip = model.trips[i]

            var model = model
            model.setCurrentTrip(trip: trip)

            let contentView = TripDetailsContentView(frame: self.contentView.frame)
            contentView.setup(model: model)

            dotsView.addDots(count: 1)
            contentView.hideCallback = hide

            contentContainerWidthConstraint.constant += containerWidth
            contentContainerView.addArrangedSubview(contentView)
        }
    }

    private func setupObservables() {
        tripsFetchedObservable
            .subscribe(onNext: { tripModels in
                if var model = tripModels.first(where: { tripModel in
                    return tripModel.currentTrip.filterId == self.tripModel.currentTrip.filterId
                }) {
                    if model.trips.count > self.contentContainerView.arrangedSubviews.count {
                        let diff = model.trips.count - self.contentContainerView.arrangedSubviews.count
                        for _ in 0 ..< diff {
                            let contentView = TripDetailsContentView(frame: self.contentView.frame)
                            self.contentContainerView.addArrangedSubview(contentView)
                            self.dotsView.addDots(count: 1)
                        }
                    } else {
                        let diff = abs(self.contentContainerView.arrangedSubviews.count - model.trips.count)
                        for _ in 0 ..< diff {
                            self.contentContainerView.removeArrangedSubview(self.contentContainerView.arrangedSubviews.last!)
                            self.dotsView.removeDots(count: 1)
                        }
                    }

                    for i in 0 ..< model.trips.count {
                        let trip = model.trips[i]
                        model.setCurrentTrip(trip: trip)

                        let contentView = self.contentContainerView.arrangedSubviews[i] as! TripDetailsContentView

                        contentView.setup(model: model)
                        contentView.hideCallback = self.hide
                    }

                    self.contentContainerWidthConstraint.constant = self.containerWidth * CGFloat(model.trips.count)

                    print(self.currentPageIndex())
                    if model.trips.count == 1 {
                        self.dotsView.activateDot(index: 0)
                    } else if self.currentPageIndex() >= model.trips.count {
                        self.dotsView.activateDot(index: model.trips.count - 1)
                    } else {
                        self.dotsView.activateDot(index: self.currentPageIndex())
                    }
                } else {
                    self.hide()
                }
            })
            .disposed(by: disposeBag)
    }
}
