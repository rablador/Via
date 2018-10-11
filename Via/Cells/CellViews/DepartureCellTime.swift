import UIKit

@IBDesignable
class DepartureCellTime: XibView {

    @IBOutlet private weak var container: UIStackView!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var timeExtra: UILabel!
    @IBOutlet private weak var timeNext: UILabel!
    @IBOutlet private weak var timeExtraNext: UILabel!
    @IBOutlet private weak var timeFuture: UILabel!
    @IBOutlet private weak var timeFutureNext: UILabel!
    @IBOutlet private weak var timeContainer: UIStackView!
    @IBOutlet private weak var timeFutureContainer: UIStackView!

    func setup(model: DepartureCellModelItem) {
        time.font = time.font.monospacedNumbers()
        timeExtra.font = timeExtra.font.monospacedNumbers()
        timeNext.font = timeNext.font.monospacedNumbers()
        timeExtraNext.font = timeExtraNext.font.monospacedNumbers()
        timeFuture.font = timeFuture.font.monospacedNumbers()
        timeFutureNext.font = timeFutureNext.font.monospacedNumbers()

        if Time.isFuture {
            timeFutureNext.isHidden = true
            timeFuture.text = model.time

            if let timeNext = model.timeNext {
                timeFutureNext.text = timeNext
                timeFutureNext.isHidden = false
            }

            toggle(isFuture: true)
        } else {
            timeNext.superview?.isHidden = true
            timeExtra.isHidden = true

            let timeLeft = Int(model.timeLeft) ?? 0
            let isOverHour = timeLeft > 60

            if isOverHour {
                let hours = Int(timeLeft / 60)
                let minutes = timeLeft - (hours * 60)

                timeExtra.text = String(hours) + "h"
                time.text = String(minutes)

                timeExtra.isHidden = false
            } else {
                time.text = model.timeLeft
            }

            if let timeLeftNext = model.timeLeftNext {
                timeExtraNext.isHidden = true

                let timeLeft = Int(timeLeftNext) ?? 0
                let isOverHour = timeLeft > 60

                if isOverHour {
                    let hours = Int(timeLeft / 60)
                    let minutes = timeLeft - (hours * 60)

                    timeExtraNext.text = String(hours) + "h"
                    timeNext.text = String(minutes)

                    timeExtraNext.isHidden = false
                } else {
                    timeNext.text = timeLeftNext
                }

                timeNext.superview?.isHidden = false
            }

            toggle(isFuture: false)
        }
    }

    private func toggle(isFuture: Bool) {
        timeContainer.isHidden = isFuture
        timeFutureContainer.isHidden = !isFuture
    }
}
