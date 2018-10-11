import UIKit

@IBDesignable
class DepartureDetailsFooterView: XibView {

    @IBOutlet private weak var newCommuteButton: UIButton!

    var model: DepartureCellModelItem!

    func setup(model: DepartureCellModelItem) {
        self.model = model
    }

    @IBAction private func didPressNewCommuteButton(_ sender: UIButton) {
        
    }
}
