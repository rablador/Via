import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSTimeZone.default = TimeZone(abbreviation: "CET")!

        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: Constants.UserDefaults.firstTimeStartup.rawValue) {
            userDefaults.set(true, forKey: Constants.UserDefaults.firstTimeStartup.rawValue)
            userDefaults.set(UUID().uuidString, forKey: Constants.UserDefaults.authScope.rawValue)
            userDefaults.synchronize()

            Favorite.defaultFavorite.save()
        }

        Fabric.with([Crashlytics.self])

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
