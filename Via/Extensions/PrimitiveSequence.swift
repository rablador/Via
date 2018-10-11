import Moya
import RxSwift
import ObjectMapper

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    func parseAuthResponse() -> Observable<Any> {
        return asObservable()
            .filterSuccessfulStatusCodes()
            .retryDelayed()
            .catchError { return Observable.error(DebugError($0.localizedDescription, type: .api)) }
            .mapJSON()
    }

    func parseApiResponse() -> Observable<Any> {
        return asObservable()
            .filterSuccessfulStatusCodes()
            .retryWithAuth()
            .retryDelayed()
            .catchError { return Observable.error(DebugError($0.localizedDescription, type: .api)) }
            .mapJSON()
    }
}
