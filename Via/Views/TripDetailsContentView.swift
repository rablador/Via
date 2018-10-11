import UIKit
import RxSwift

class TripDetailsContentView: DepartureDetailsContentBaseView {

    private var tripModel: TripCellModel!
    private var currentDestinations: [Stop]?

    let cellHeight: CGFloat = 46
    let legCellHeight: CGFloat = 92
    let legDoubleCellHeight: CGFloat = 111
    let legDoubleCellPartHeight: CGFloat = 65

    func setup(model: TripCellModel) {
        currentOrigin = StopDataHandler.shared.currentOrigin
        currentDestinations = StopDataHandler.shared.currentDestinations

        setupObservables()

        manager.startManaging(withDelegate: self)
        manager.register(TripDetailsLineCell.self) { $0.condition = .section(0) }
        manager.register(TripDetailsDoubleCell.self) { $0.condition = .section(1) }
        manager.register(TripDetailsCell.self) { $0.condition = .section(2) }

        manager.configure(TripDetailsLineCell.self) { (cell, cellModel, indexPath) in
            cell.setupLine(color: cellModel.fgColor)
        }

        manager.configure(TripDetailsDoubleCell.self) { (cell, cellModel, indexPath) in
            cell.setupLines(topColor: cellModel.legModel1.fgColor, bottomColor: cellModel.legModel2.fgColor)
        }

        manager.configure(TripDetailsCell.self) { (cell, cellModel, indexPath) in
            cell.setupLine(color: cellModel.fgColor)
        }

        manager.heightForCell(withItem: LegCellModel.self) { (cellModel, indexPath) -> CGFloat in
            if indexPath.section == 0 {
                return self.legCellHeight
            } else if indexPath.section == 2 {
                return self.cellHeight
            } else {
                return 0
            }
        }

        manager.heightForCell(withItem: LegDoubleCellModel.self) { (cellModel, indexPath) -> CGFloat in
            if indexPath.section == 1 {
                return self.legDoubleCellHeight
            } else {
                return 0
            }
        }

        refresh(model: model)
    }

    private func refresh(model: TripCellModel) {
        tripModel = model
        infoLabel.fadeOut()

        if var legs = model.legs {
            let firstLeg = legs.first!

            storage.setItems([LegCellModel(leg: firstLeg)], forSection: 0)

            if legs.count > 1 {
                var items = [LegDoubleCellModel]()

                for i in 0 ..< legs.count {
                    if i == (legs.count - 1) { break }

                    let model1 = LegCellModel(leg: legs[i])
                    let model2 = LegCellModel(leg: legs[i + 1])
                    items.append(LegDoubleCellModel(legModel1: model1, legModel2: model2))
                }

                storage.setItems(items, forSection: 1)
                storage.setItems([LegCellModel(leg: legs.last!)], forSection: 2)
            } else {
                storage.setItems([LegCellModel(leg: firstLeg)], forSection: 2)
            }
        } else {
            infoLabel.fadeIn()
        }
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
            .subscribe(onNext: { stops in
                if let stops = stops, let currentStops = self.currentDestinations {
                    for stop in stops {
                        if !currentStops.contains(stop) {
                            self.hideCallback?()
                            return
                        }
                    }
                } else {
                    self.hideCallback?()
                }

                self.currentDestinations = stops
            })
            .disposed(by: disposeBag)
    }
}
