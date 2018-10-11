import UIKit
import DTModelStorage

class DepartureDetailsCell: UITableViewCell {

    @IBOutlet private weak var cellView: DepartureDetailsCellView!

    func setupLines(topColor: UIColor, bottomColor: UIColor) {
        cellView.setupLines(topColor: topColor, bottomColor: bottomColor)
    }
}

extension DepartureDetailsCell: ModelTransfer {

    func update(with model: JourneyDetailStopCellModel) {
        cellView.setup(model: model)
    }
}
