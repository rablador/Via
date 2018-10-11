import PromiseKit

extension Promise where T == Void {

    static var emptyPromise: Promise<T> {
        return Promise<T>()
    }
}
