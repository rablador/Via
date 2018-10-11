import Foundation

class DebugError: Error {

    enum Kind: String {

        case general
        case api
        case network
        case timeout
        case location
        case fatal
        case debug
    }

    let type: Kind
    let localizedDescription: String

    init(_ message: String, type: Kind = .general, file: String = #file, function: String = #function, line: Int = #line) {
        self.type = type

        let file = file.split(separator: "/").last
        let metaInfo = "\(file ?? "") - \(function) - \(line)"

        localizedDescription = "ViaError: \(message)\n@ \(metaInfo)"
    }
}

extension DebugError {

    var humanReadableError: String {
        switch type {
        case .general, .fatal:
            return "Ett fel uppstod. Försök igen senare."
        case .api:
            return "Kunde inte hämta information från Västtrafik. Försök igen senare."
        case .network:
            return "Ingen uppkoppling!\nKontrollera din uppkoppling och försök igen senare."
        case .timeout:
            return "Dålig uppkoppling?\nKontrollera din uppkoppling och försök igen senare."
        case .location:
            return "Kunde inte hitta din nuvarande position.\nKontrollera att GPS är påslaget och försök igen senare."
        default:
            return ""
        }
    }
}
