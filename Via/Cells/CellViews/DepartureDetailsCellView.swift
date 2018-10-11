import UIKit

@IBDesignable
class DepartureDetailsCellView: XibView {

    @IBOutlet private weak var topLine: UIView!
    @IBOutlet private weak var bottomLine: UIView!
    @IBOutlet private weak var stopIcon: UIImageView!
    @IBOutlet private weak var stopTime: UILabel!
    @IBOutlet private weak var stopStop: UILabel!
    @IBOutlet private weak var stopTrack: UILabel!

    func setup(model: LegCellModel, to: Bool = true) {
        setupTrack()

        stopTime.font = stopTime.font.monospacedNumbers()
        stopTime.text = to ? model.stopTime : model.startTime

        stopStop.text = to ? model.stopStop : model.startStop

        stopTrack.text = to ? model.stopTrack : model.startTrack
        stopTrack.isHidden = stopTrack.text == ""
    }

    func setup(model: JourneyDetailStopCellModel) {
        setupTrack()

        stopTime.font = stopTime.font.monospacedNumbers()
        stopTime.text = model.stopTime

        stopStop.text = model.stopStop

        stopTrack.text = model.stopTrack
        stopTrack.isHidden = stopTrack.text == ""
    }

    func setupLines(topColor: UIColor, bottomColor: UIColor) {
        topLine.backgroundColor = topColor
        bottomLine.backgroundColor = bottomColor
    }

    private func setupTrack() {
        stopTrack.layer.borderColor = UIColor.blue4.cgColor
        stopTrack.layer.borderWidth = 1
        stopTrack.layer.cornerRadius = 2
    }
}
