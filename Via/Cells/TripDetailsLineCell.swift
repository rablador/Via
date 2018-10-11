import UIKit
import DTModelStorage

class TripDetailsLineCell: UITableViewCell {

    @IBOutlet private weak var cellView: DepartureDetailsCellView!
    @IBOutlet private weak var lineCellView: TripDetailsLineCellView!

    func setupLine(color: UIColor) {
        cellView.setupLines(topColor: .clear, bottomColor: color)
        lineCellView.setupLine(color: color)
    }
}

extension TripDetailsLineCell: ModelTransfer {

    func update(with model: LegCellModel) {
        cellView.setup(model: model, to: false)
        lineCellView.setup(model: model)
    }
}
