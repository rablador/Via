import UIKit

@IBDesignable
class DepartureDetailsHeaderView: XibView {

    @IBOutlet private weak var lineView: DepartureCellLine!
    @IBOutlet private weak var direction: UILabel!
    @IBOutlet private weak var closeButton: UIButton!

    var closeButtonCallback: Callback?

    func setup(model: DepartureCellModelItem) {
        lineView.setup(model: model)
        direction.text = model.direction
    }

    @IBAction private func didPressCloseButton(_ sender: UIButton) {
        closeButtonCallback?()
    }
}
