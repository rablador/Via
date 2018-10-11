import UIKit
import RxSwift

@IBDesignable
class SearchInputView: XibView {

    @IBOutlet private weak var textField: UITextField!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.keyboardAppearance = .dark
        textField.tintColor = .blue5

        textField.rx.text
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { searchString in
                guard let searchString = searchString else { return }
                PublishSubjects.shared.searchInputSubject.onNext(searchString)
            })
            .disposed(by: disposeBag)
    }

    func getText() -> String {
        return textField.text ?? ""
    }

    func activate(placeholder: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : UIColor.blue4])
        textField.text = ""

        showKeyboard()
        fadeIn()
    }

    func deactivate() {
        hideKeyboard()
        fadeOut()
    }

    func showKeyboard() {
        textField.becomeFirstResponder()
    }

    func hideKeyboard() {
        textField.endEditing(true)
    }
}
