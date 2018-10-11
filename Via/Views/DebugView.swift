import UIKit
import RxSwift

class DebugView: XibView {

    @IBOutlet private weak var textView: UITextView!

    private let debugInfoUpdatedObservable: Observable<String> = PublishSubjects.shared.debugInfoUpdatedSubject
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(text: String) {
        textView.text = textView.text + text
    }

    @IBAction private func didTapClearButton(_ sender: UIButton) {
        textView.text = ""
    }
}
