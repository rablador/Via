import Alamofire

class VasttraikSessionManager: Alamofire.SessionManager {

    static let shared: VasttraikSessionManager = {
        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.requestCachePolicy = .useProtocolCachePolicy

        return VasttraikSessionManager(configuration: configuration)
    }()
}
