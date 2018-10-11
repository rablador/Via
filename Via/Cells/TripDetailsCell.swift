import UIKit
import DTModelStorage

class TripDetailsCell: UITableViewCell {

    @IBOutlet private weak var cellView: DepartureDetailsCellView!

    func setupLine(color: UIColor) {
        cellView.setupLines(topColor: color, bottomColor: .clear)
    }
}

extension TripDetailsCell: ModelTransfer {

    func update(with model: LegCellModel) {
        cellView.setup(model: model)
    }
}
