import UIKit

@IBDesignable
class TripDetailsDoubleCellView: XibView {

    @IBOutlet private weak var topLine: UIView!
    @IBOutlet private weak var bottomLine: UIView!
    @IBOutlet private weak var stopIcon: UIImageView!
    @IBOutlet private weak var stopTimeTo: UILabel!
    @IBOutlet private weak var stopTimeFrom: UILabel!
    @IBOutlet private weak var stopStop: UILabel!
    @IBOutlet private weak var stopTrackTo: UILabel!
    @IBOutlet private weak var stopTrackFrom: UILabel!

    func setup(model1: LegCellModel, model2: LegCellModel) {
        stopTrackTo.layer.borderColor = UIColor.blue4.cgColor
        stopTrackTo.layer.borderWidth = 1
        stopTrackTo.layer.cornerRadius = 2
        stopTrackTo.text = model1.stopTrack
        stopTrackTo.isHidden = stopTrackTo.text == ""

        stopTrackFrom.layer.borderColor = UIColor.blue4.cgColor
        stopTrackFrom.layer.borderWidth = 1
        stopTrackFrom.layer.cornerRadius = 2
        stopTrackFrom.text = model2.startTrack
        stopTrackFrom.isHidden = stopTrackFrom.text == ""

        stopTimeTo.font = stopTimeTo.font.monospacedNumbers()
        stopTimeTo.text = model1.stopTime

        stopTimeFrom.font = stopTimeFrom.font.monospacedNumbers()
        stopTimeFrom.text = model2.startTime

        stopStop.text = model2.startStop
    }

    func setupLines(topColor: UIColor, bottomColor: UIColor) {
        topLine.backgroundColor = topColor
        bottomLine.backgroundColor = bottomColor
    }
}
