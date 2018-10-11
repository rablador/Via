import RxSwift
import ObjectMapper
import Moya

extension ObservableType {

    public func mapObject<T: VasttrafikObjectMappable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            guard let json = data as? JSON, let object = T.jsonToObject(json) as? T else {
                return Observable.error(DebugError("Mapper can't map to \(T.self)."))
            }

            return Observable.just(object)
        }
    }

    public func mapArray<T: VasttrafikArrayMappable>(type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            guard let json = data as? JSON, let objects = T.jsonToArray(json) as? [T] else {
                return Observable.error(DebugError("Mapper can't map to [\(T.self)]."))
            }

            return Observable.just(objects)
        }
    }
}

extension ObservableType where E == Response {

    func retryDelayed() -> Observable<Response> {
        return retry(.delayed(maxCount: 2, time: 2), shouldRetry: { error in
            self.responseStatusCode(from: error) != 401
        })
    }

    func retryWithAuth() -> Observable<Response> {
        return retryWhen { $0.flatMap { error -> Observable<AccessToken> in
            if self.responseStatusCode(from: error) == 401 {
                return VasttrafikService().getAccessToken()
                    .catchError { Observable.error(DebugError($0.localizedDescription, type: .api)) }
                    .flatMapLatest { Observable.just($0) }
            } else {
                return Observable.error(error)
            }
        }}
    }
}

extension ObservableType {

    private func responseStatusCode(from error: Error) -> Int? {
        return (error as? MoyaError)?.response?.statusCode
    }
}
