import UIKit

@IBDesignable
class TimePlannerView: XibView {

    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var okButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fadeView: UIView!

    var okCallback: Callback?
    var changeCallback: ValueCallback<(date: Date, isDeparture: Bool)>?
    var willRemoveCallback: Callback?
    var didRemoveCallback: Callback?

    func setup(date: Date, isDeparture: Bool, okCallback: Callback? = nil, changeCallback: ValueCallback<(date: Date, isDeparture: Bool)>? = nil, willRemoveCallback: Callback? = nil, didRemoveCallback: Callback? = nil) {
        self.okCallback = okCallback
        self.changeCallback = changeCallback
        self.willRemoveCallback = willRemoveCallback
        self.didRemoveCallback = didRemoveCallback

        datePicker.setDate(date, animated: false)
        datePicker.minimumDate = Date()
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")

        segmentedControl.selectedSegmentIndex = isDeparture ? 0 : 1

        changeCallback?((date: datePicker.date, isDeparture: segmentedControl.selectedSegmentIndex == 0))
    }

    func toggleDepartureControl(isEnabled: Bool, isDeparture: Bool) {
        segmentedControl.setEnabled(isEnabled, forSegmentAt: 1)
        segmentedControl.selectedSegmentIndex = isEnabled && !isDeparture ? 1 : 0
    }

    func show() {
        fadeView.fadeIn(duration: .fast)

        containerTopConstraint.constant = 0
        UIView.animate(duration: .fade, animations: { self.layoutIfNeeded() })
    }

    func hide() {
        willRemoveCallback?()
        fadeView.fadeOut(duration: .fast)

        containerTopConstraint.constant = -container.height - 58 // -58 for TimeView
        UIView.animate(duration: .fade, animations: { self.layoutIfNeeded() }, completion: { self.didRemoveCallback?() })
    }

    @IBAction private func didSwipeUp(_ sender: UISwipeGestureRecognizer) {
        hide()
    }

    @IBAction private func didTap(_ sender: UITapGestureRecognizer) {
        hide()
    }

    @IBAction func didPressOkButton(_ sender: UIButton) {
        okCallback?()
    }

    @IBAction func datePickerDidChange(_ sender: UIDatePicker) {
        changeCallback?((date: datePicker.date, isDeparture: segmentedControl.selectedSegmentIndex == 0))
    }

    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        changeCallback?((date: datePicker.date, isDeparture: segmentedControl.selectedSegmentIndex == 0))
    }
}
