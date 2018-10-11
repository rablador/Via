import UIKit

@IBDesignable
class TripDetailsLineCellView: XibView {

    @IBOutlet private weak var line: UIView!
    @IBOutlet private weak var lineView: DepartureCellLine!
    @IBOutlet private weak var direction: UILabel!
    @IBOutlet private weak var accessibility: UIImageView!

    func setup(model: LegCellModel) {
        lineView.setup(model: model)
        direction.text = model.direction
        if model.accessibility == .wheelChair { accessibility.isHidden = false }
    }

    func setupLine(color: UIColor) {
        line.backgroundColor = color
    }
}
