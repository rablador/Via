import UIKit
import RxSwift

class InfoLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(error: Error) {
        if let viaError = error as? DebugError {
            text = viaError.humanReadableError
            fadeIn(duration: .fade)
        }
    }

    func set(text: String) {
        self.text = text
        fadeIn(duration: .fade)
    }

    func clear() {
        text = ""
        fadeOut(duration: .fade)
    }
}
