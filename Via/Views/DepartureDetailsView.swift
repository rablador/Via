import UIKit
import RxSwift

class DepartureDetailsView: DepartureDetailsBaseView {

    @IBOutlet weak var contentView: DepartureDetailsContentView!
    @IBOutlet weak var footerHeightConstraint: NSLayoutConstraint!

    private let departuresFetchedObservable: Observable<[DepartureCellModel]> = PublishSubjects.shared.departuresFetchedSubject
    private let disposeBag = DisposeBag()

    private var containerWidth: CGFloat!
    private var departureModel: DepartureCellModel!

    func setup(model: DepartureCellModel, origHeight: CGFloat) {
        setupConstraints()
        setupObservables()

        departureModel = model
        containerWidth = superview!.width - 20

        headerView.setup(model: model)
        contentView.setup(model: model)
        footerView.setup(model: model)

        scrollView.delegate = self
        contentView.hideCallback = hide

        let nonContentHeight = container.height - scrollView.height
        let wholeVisibleRows = Int(scrollView.height / contentView.cellHeight) - (isiPhoneX ? 0 : 3)
        var contentHeight = CGFloat(wholeVisibleRows) * contentView.cellHeight
        contentHeight = min(contentHeight, (origHeight - 58) - nonContentHeight) // -58 for TimeView

        containerHeightConstraint.constant = contentHeight + nonContentHeight + (isiPhoneX ? 2 : 0)
        contentContainerWidthConstraint.constant = containerWidth
        footerHeightConstraint.constant += isiPhoneX ? 2 : 0

        for i in 1 ..< model.departures.count {
            let departure = model.departures[i]

            var model = model
            model.setCurrentDeparture(departure: departure)

            let contentView = DepartureDetailsContentView(frame: self.contentView.frame)
            contentView.setup(model: model)

            dotsView.addDots(count: 1)
            contentView.hideCallback = hide

            contentContainerWidthConstraint.constant += containerWidth
            contentContainerView.addArrangedSubview(contentView)
        }
    }

    private func setupObservables() {
        departuresFetchedObservable
            .subscribe(onNext: { departureModels in
                if var model = departureModels.first(where: { departureModel in
                    return self.departureModel.currentDeparture.filterId == departureModel.currentDeparture.filterId
                }) {
                    if model.departures.count > self.contentContainerView.arrangedSubviews.count {
                        let diff = model.departures.count - self.contentContainerView.arrangedSubviews.count
                        for _ in 0 ..< diff {
                            let contentView = DepartureDetailsContentView(frame: self.contentView.frame)
                            self.contentContainerView.addArrangedSubview(contentView)
                            self.dotsView.addDots(count: 1)
                        }
                    } else {
                        let diff = abs(self.contentContainerView.arrangedSubviews.count - model.departures.count)
                        for _ in 0 ..< diff {
                            self.contentContainerView.removeArrangedSubview(self.contentContainerView.arrangedSubviews.last!)
                            self.dotsView.removeDots(count: 1)
                        }
                    }

                    for i in 0 ..< model.departures.count {
                        let departure = model.departures[i]
                        model.setCurrentDeparture(departure: departure)

                        let contentView = self.contentContainerView.arrangedSubviews[i] as! DepartureDetailsContentView

                        contentView.setup(model: model)
                        contentView.hideCallback = self.hide
                    }

                    self.contentContainerWidthConstraint.constant = self.containerWidth * CGFloat(model.departures.count)

                    if model.departures.count == 1 {
                        self.dotsView.activateDot(index: 0)
                    } else if self.currentPageIndex() >= model.departures.count {
                        self.dotsView.activateDot(index: model.departures.count - 1)
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
