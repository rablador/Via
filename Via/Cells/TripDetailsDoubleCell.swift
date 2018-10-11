import UIKit
import DTModelStorage

class TripDetailsDoubleCell: UITableViewCell {

    @IBOutlet private weak var doubleCellView: TripDetailsDoubleCellView!
    @IBOutlet private weak var lineCellView: TripDetailsLineCellView!

    func setupLines(topColor: UIColor, bottomColor: UIColor) {
        doubleCellView.setupLines(topColor: topColor, bottomColor: bottomColor)
        lineCellView.setupLine(color: bottomColor)
    }
}

extension TripDetailsDoubleCell: ModelTransfer {

    func update(with model: LegDoubleCellModel) {
        doubleCellView.setup(model1: model.legModel1, model2: model.legModel2)
        lineCellView.setup(model: model.legModel2)
    }
}
