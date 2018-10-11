import Moya

class VasttrafikProvider {

    static let shared = MoyaProvider<VasttrafikTarget>(manager: VasttraikSessionManager.shared)
}
