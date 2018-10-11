import UIKit

var extraTop: CGFloat {
    if #available(iOS 11.0, *) { return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 }
    return 0
}

var extraBottom: CGFloat {
    if #available(iOS 11.0, *) { return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 }
    return 0
}

var hasSafeAreaInsets: Bool {
    if (extraTop > 0) && (extraBottom > 0) { return true }
    return false
}

var isiPhoneX: Bool {
    let screenSize = UIScreen.main.bounds.size
    let width = screenSize.width
    let height = screenSize.height

    return (min(width, height) == 375) && (max(width, height) == 812)
}

var isDebug: Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}

func debugErrorPrint(_ error: Error) {
    guard let viaError = error as? DebugError else {
        debugPrint(error.localizedDescription)
        return
    }

    if isDebug {
        var message = "\n"
        message += viaError.type.rawValue + "\n"
        message += "---" + "\n"
        message += viaError.localizedDescription + "\n"
        debugPrint(message)
    } else {
//        Crashlytics.sharedInstance().recordError(error)
    }
}

func debugPrint(_ message: Any, _ rawFormat: Bool = false) {
    if isDebug {
        let formattedMessage = rawFormat ? String(describing: message) : "\n" + String(describing: message) + "\n"

        Swift.print(formattedMessage)
        PublishSubjects.shared.debugInfoUpdatedSubject.onNext(formattedMessage)
    }
}
